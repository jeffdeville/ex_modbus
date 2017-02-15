defmodule ExModbus do
  # defmacro __using__(_opts) do
    # alias ExModbus.Client
    # import ExModbus.Types
  # end
  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :locales, accumulate: true,
                                                      persist: false
      import unquote(__MODULE__), only: [field: 6, field: 7]
    end
  end

  defmacro field(name, type, addr, num_bytes, perms, desc) do
    quote do
      @doc """
      # Description:

      unquote(desc)

      * Field Type: unquote(type)
      """

      # if readable
      def unquote(name)(pid, slave_id \\ 1) do
        # IO.puts inspect [unquote(name), pid, slave_id]
        case ExModbus.Client.read_data(pid, slave_id, unquote(addr - 1), unquote(num_bytes)) do
          {:ok, %{data: {:read_holding_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
            with {:ok, value} = data |> ExModbus.Types.convert_type(unquote(type))
            do
              {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
            else
              {:type_conversion_error, type} -> {:type_conversion_error, type}
            end
          other ->
            IO.puts inspect other
        end
      end
    end
  end

  defmacro field(name, type, addr, num_bytes, perms, desc, data_mapper) do
    quote do
      @doc """
      # Description:

      unquote(desc)

      * Field Type: unquote(type)
      """

      # if readable
      def unquote(name)(pid, slave_id \\ 1) do
        case ExModbus.Client.read_data(pid, slave_id, unquote(addr - 1), unquote(num_bytes)) do
          {:ok, %{data: {:read_holding_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
            with {:ok, value} = data |> ExModbus.Types.convert_type(unquote(type)),
                 value = unquote(data_mapper).(value)
            do
              {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
            else
              {:type_conversion_error, type} -> {:type_conversion_error, type}
            end
          other ->
            IO.puts inspect other
        end
      end
    end
  end
end
