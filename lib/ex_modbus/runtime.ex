defmodule ExModbus.Runtime do
  alias ExModbus.Types

  require Logger

  def get_fields(pid, slave_id, addr, num_bytes, fields) do
    with {:ok, %{data: {:read_holding_registers, data},
                 transaction_id: transaction_id,
                 unit_id: unit_id}} <- ExModbus.Client.read_data(pid, slave_id, addr, num_bytes),
         results = map_results(data, fields, transaction_id, unit_id)
    do
         assert_valid_results(results)
    end
  end

  def map_results("", [], _, _), do: []
  def map_results(data, [{name, type, num_registers, enum_map} | fields], txn_id, unit_id) do
    num_bytes = ExModbus.Types.size_in_bytes(type, num_registers)

    with <<data::binary-size(num_bytes)-big, rest::binary>> <- data,
         {:ok, %{data: value}} <- map_data(data, txn_id, unit_id, type, enum_map),
         results = map_results(rest, fields, txn_id, unit_id)
    do
      results ++ [{:ok, {name, value}}]
    end
  end

  defp assert_valid_results(results) do
    all_valid = Enum.all?(results, fn
        {:ok, _val} -> true
        _ -> false
      end)
    case all_valid do
      true ->
        mapped_results = results
          |> Enum.map(fn {:ok, val} -> val end)
          |> Enum.into(%{})
        {:ok, mapped_results}
      false ->
        Logger.error("Unable to map all results: #{inspect results}")
        {:error, :mapping_error}
    end
  end

  def get_field(pid, slave_id, addr, num_bytes, type, enum_map \\ %{}) do
    with  {:ok, %{data: {:read_holding_registers, data},
                  transaction_id: transaction_id,
                  unit_id: unit_id}} <- ExModbus.Client.read_data(pid, slave_id, addr, num_bytes)
    do
      map_data(data, transaction_id, unit_id, type, enum_map)
    end
  end

  def map_data(data, transaction_id, unit_id, type, enum_map \\ %{}) do
    with {:ok, value} <- Types.from_binary(data, type),
         {:ok, value} <- Types.bitfield_to_enum(type, enum_map, value)
    do
      {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
    else
      {:ok, %{data: {:read_holding_registers_exception, _}} = data} -> {:read_holding_registers_exception, data}
      {:type_conversion_error, {data, type}} -> {:type_conversion_error, {data, type}}
      {:enum_not_found_error, message} -> {:enum_not_found_error, message}
    end
  end

  def set_field(pid, slave_id, data, addr, type, enum_map \\ %{}) do
    with {:ok, mapped_value} <- Types.to_binary(data, type, enum_map),
         {:ok, %{data: {:write_multiple_registers, data}, transaction_id: transaction_id, unit_id: unit_id}}
            <- ExModbus.Client.write_multiple_registers(pid, slave_id, addr, mapped_value)
    do
         {:ok, %{data: data, transaction_id: transaction_id, slave_id: unit_id}}
    else
         {:ok, %{data: {:write_multiple_registers_exception, _}} = data} -> {:write_multiple_registers_exception, data}
         {error, message} -> {error, message}
    end
  end
end
