defmodule ExModbus do
  alias ExModbus.Macros

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

  defmacro field(name, type, addr, num_registers, perms, desc, opts \\ []) do
    units = Keyword.get(opts, :units, "")
    enum_map = Keyword.get(opts, :enum_map, Macro.escape(%{}))
    quote bind_quoted: [name: name, type: type, addr: addr,
                        num_registers: num_registers, perms: perms, desc: desc,
                        units: units, enum_map: enum_map] do
      @fields {name, type, addr, num_registers, perms, desc, "", enum_map}
    end
  end

  defmacro field_group(name, fields, desc \\ "") do
    quote bind_quoted: [name: name, fields: fields, desc: desc] do
      @field_groups {name, fields, desc}
    end
  end

  def compile(fields, field_groups) do
    fields_ast = for {name, type, addr, num_registers, perms, desc, units, enum_map} <- fields do
      getter_ast = Macros.defgetter(name, type, addr, num_registers, desc, units, enum_map)
      case perms do
        :r -> getter_ast
        :rw -> [Macros.defsetter(String.to_atom("set_" <> Atom.to_string(name)), type, addr, num_registers, desc, units, enum_map) | [getter_ast] ]
      end
    end

    field_groups_ast = for {name, include_fields, desc} <- field_groups do
      Macros.defgroupgetter(name, include_fields, fields, desc)
    end

    quote do
      def field_defs(), do: @fields
      def field_groups(), do: @field_groups
      unquote(fields_ast)
      unquote(field_groups_ast)
    end
  end
end
