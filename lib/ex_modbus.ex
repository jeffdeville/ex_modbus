defmodule ExModbus do
  alias ExModbus.ModelBuilder

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :fields, accumulate: true, persist: false
      Module.register_attribute __MODULE__, :field_groups, accumulate: true, persist: false
      require Logger
      import unquote(__MODULE__), only: [field: 6, field: 7, field_group: 2]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :fields), Module.get_attribute(env.module, :field_groups))
  end

  defmacro field(name, type, addr, num_bytes, perms, desc, opts \\ []) do
    units = Keyword.get(opts, :units, "")
    enum_map = Keyword.get(opts, :enum_map, Macro.escape(%{}))
    quote bind_quoted: [name: name, type: type, addr: addr,
                        num_bytes: num_bytes, perms: perms, desc: desc,
                        units: units, enum_map: enum_map] do
      @fields {name, type, addr, num_bytes, perms, desc, "", enum_map}
    end
  end

  defmacro field_group(name, fields, desc \\ "") do
    quote bind_quoted: [name: name, fields: fields, desc: desc] do
      @field_groups {name, fields, desc}
    end
  end

  def compile(fields, field_groups) do
    fields_ast = for {name, type, addr, num_bytes, perms, desc, units, enum_map} <- fields do
      getter_ast = ModelBuilder.defgetter(name, type, addr, num_bytes, desc, units, enum_map)
      case perms do
        :r -> getter_ast
        :rw -> [ModelBuilder.defsetter(String.to_atom("set_" <> Atom.to_string(name)), type, addr, num_bytes, desc, units, enum_map) | [getter_ast] ]
      end
    end

    field_groups_ast = for {name, include_fields, desc} <- field_groups do
      ModelBuilder.defgroupgetter(name, include_fields, fields, desc)
    end

    quote do
      def field_defs(), do: @fields
      def field_groups(), do: @field_groups

      defp map_results("", [], _, _), do: []
      defp map_results(data, [{name, type, addr, num_bytes, _, _, _, _} | fields], txn_id, unit_id) do
        num_bytes = get_real_byte_size(type, num_bytes)
        <<val::binary-size(num_bytes)-big, rest::binary>> = data
        with {:ok, %{data: value}} <- apply(__MODULE__, name, [val, txn_id, unit_id]),
             results = map_results(rest, fields, txn_id, unit_id)
        do
          results ++ [{:ok, {name, value}}]
        end
      end

      defp get_real_byte_size(:string, num_bytes), do: num_bytes
      defp get_real_byte_size(:bitfield32, _num_bytes), do: 4
      defp get_real_byte_size(:bitfield16, _num_bytes), do: 2
      defp get_real_byte_size(:int16, _num_bytes), do: 2
      defp get_real_byte_size(:enum16, _num_bytes), do: 2
      defp get_real_byte_size(:uint16, _num_bytes), do: 2
      defp get_real_byte_size(:uint32, _num_bytes), do: 4
      defp get_real_byte_size(:sunssf, num_bytes), do: num_bytes
      defp get_real_byte_size(:sunssf, num_bytes), do: num_bytes
      defp get_real_byte_size(:float32, _num_bytes), do: 4
      defp get_real_byte_size(:string32, _num_bytes), do: 4
      defp get_real_byte_size(:string16, _num_bytes), do: 2

      defp assert_valid_results(results) do
        all_valid = Enum.all?(results, fn
            {:ok, val} -> true
            _ -> false
          end)
        case all_valid do
          true -> Enum.map(results, fn {:ok, val} -> val end)
          false -> raise ArgumentError, "Unable to map all results. #{inspect results}"
        end
      end

      unquote(fields_ast)
      unquote(field_groups_ast)
    end
  end
end
