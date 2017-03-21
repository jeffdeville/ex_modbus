defmodule ExModbus do
  alias ExModbus.ModelBuilder

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :fields, accumulate: true, persist: false
      require Logger
      import unquote(__MODULE__), only: [field: 6, field: 7]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :fields))
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

  def compile(fields) do
    ast = for {name, type, addr, num_bytes, perms, desc, units, enum_map} <- fields do
      getter_ast = ModelBuilder.defgetter(name, type, addr, num_bytes, desc, units, enum_map)
      case perms do
        :r -> getter_ast
        :rw -> [ModelBuilder.defsetter(String.to_atom("set_" <> Atom.to_string(name)), type, addr, num_bytes, desc, units) | [getter_ast] ]
      end
    end

    quote do
      def field_defs(), do: @fields
      unquote(ast)
    end
  end
end
