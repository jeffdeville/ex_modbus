defmodule ExModbus do
  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :fields, accumulate: true, persist: false
      require Logger
      import unquote(__MODULE__), only: [field: 6, field: 7, to_bytes: 2]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :fields))
  end

  defmacro field(name, type, addr, num_bytes, perms, desc, data_map \\ []) do
    quote bind_quoted: [name: name, type: type, addr: addr, num_bytes: num_bytes, perms: perms, desc: desc, data_map: data_map] do
      @fields {name, type, addr, num_bytes, perms, desc, data_map}
    end
  end

  def compile(fields) do
    # TBD: Return AST for all fields at once
    ast = for {name, type, addr, num_bytes, perms, desc, data_map} <- fields do
      getter_ast = defgetter(name, type, addr, num_bytes, desc, data_map)
      case perms do
        :r -> getter_ast
        :rw -> [defsetter(String.to_atom("set_" <> Atom.to_string(name)), type, addr, desc) | [getter_ast] ]
      end
    end

    quote do
      unquote(ast)
    end
  end

  def to_bytes(data, :int16), do: <<data::signed-integer-size(16)>>
  def to_bytes(data, :uint16), do: <<data::unsigned-integer-size(16)>>
  def to_bytes(data, :enum16, map), do: <<Map.get(map, data, data)::unsigned-integer-size(16)>>

  def defgetter(name, type, addr, num_bytes, desc, data_map \\ []) do
    quote do
      @doc """
      # Description:

      #{unquote(desc)}

      * Field Type: #{unquote(type)}
      """
      def unquote(name)(pid, slave_id \\ 1) do
        with {:ok, %{data: {:read_holding_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} <- ExModbus.Client.read_data(pid, slave_id, unquote(addr - 1), unquote(num_bytes)),
             {:ok, value} = ExModbus.Types.convert_type(data, unquote(type)),
             {:ok, value} <- apply(ExModbus, :map_enum_value, [unquote(data_map), value])
        do
          {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
        else
          {:type_conversion_error, type} -> {:type_conversion_error, type}
          {:enum_not_found_error, message} -> {:enum_not_found_error, message}
        end
      end
    end
  end

  def defsetter(name, type, addr, desc) do
    quote do
      @doc """
      # Description:

      #{unquote(desc)}

      * Field Type: #{unquote(type)}
      """
      def unquote(name)(pid, slave_id, data) do
        case ExModbus.Client.write_multiple_registers(pid, slave_id, unquote(addr - 1), to_bytes(data, unquote(type))) do
          {:ok, %{data: {:write_multiple_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
            {:ok, %{data: data, transaction_id: transaction_id, slave_id: unit_id}}
          other ->
            IO.puts inspect other
        end
      end
    end
  end

  def map_enum_value([], value), do: {:ok, value}
  def map_enum_value(data_map, value) do
    case Enum.at(data_map, value) do
      nil -> {:enum_not_found_error, "#{inspect data_map} either has no member #{value}, or it is out of range"}
      val -> val
    end
  end
end
