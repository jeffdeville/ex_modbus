defmodule ExModbus.ModelBuilder do
  alias __MODULE__
  alias ExModbus.Types

  def defgetter(name, type, addr, num_bytes, desc, units, enum_map) do
    quote do
      unquote(docs(desc, type, units))
      @spec unquote(name)(pid, integer) :: {:ok, %{data: any(), transaction_id: integer(), unit_id: integer()}} |
                                           {:type_conversion_error, {any(), any()}} |
                                           {:enum_not_found_error, String.t}
      def unquote(name)(pid, slave_id \\ 1) do
        with {:ok, %{data: {:read_holding_registers, data},
                     transaction_id: transaction_id,
                     unit_id: unit_id}} <- ExModbus.Client.read_data(pid, slave_id, unquote(addr - 1), unquote(num_bytes)),
             {:ok, value} <- Types.map_type(data, unquote(type)),
             {:ok, value} <- ModelBuilder.map_enum_value(unquote(Macro.escape(enum_map)), value)
        do
          {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
        else
          {:ok, %{data: {:read_holding_registers_exception, _}} = data} -> {:read_holding_registers_exception, data}
          {:type_conversion_error, {data, type}} -> {:type_conversion_error, {data, type}}
          {:enum_not_found_error, message} -> {:enum_not_found_error, message}
        end
      end
    end
  end

  def defsetter(name, type, addr, desc, units) do
    quote do
      unquote(docs(desc, type, units))
      @spec unquote(name)(pid, integer, any) :: :ok
      def unquote(name)(pid, slave_id, data) do
        # More work required, not sure what will be returned here.
        case ExModbus.Client.write_multiple_registers(pid, slave_id, unquote(addr - 1), ModelBuilder.to_bytes(data, unquote(type))) do
          {:ok, %{data: {:write_multiple_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
            {:ok, %{data: data, transaction_id: transaction_id, slave_id: unit_id}}
          {:ok, %{data: {:write_multiple_registers_exception, _}} = data} -> {:write_multiple_registers_exception, data}
        end
      end
    end
  end

  def docs(desc, type, units) do
    quote do
      @doc """
      #{unquote(desc)}
      * Field Type: #{unquote(type)}
      * Units: #{unquote(units)}
      """
    end
  end

  def to_bytes(data, :int16), do: <<data::signed-integer-size(16)>>
  def to_bytes(data, :uint16), do: <<data::unsigned-integer-size(16)>>
  def to_bytes(data, :enum16, map), do: <<Map.get(map, data, data)::unsigned-integer-size(16)>>

  def map_enum_value(%{} = empty_map, value) when empty_map == %{}, do: {:ok, value}
  def map_enum_value(enum_map, value) do
    case Map.get(enum_map, value) do
      nil -> {:enum_not_found_error, "#{inspect enum_map} either has no member #{value}, or it is out of range"}
      enum_val -> {:ok, enum_val}
    end
  end
end
