defmodule ExModbus.Macros do
  require Logger

  def defgroupgetter(name, include_fields, all_fields, desc \\ "") do
    # find the fields that are included. Assert that they're all found
    fields = include_fields
      |> Enum.map(&(find_by_name!(all_fields, &1)))
      |> Enum.sort(fn {_, _, addr1, _, _, _, _, _}, {_, _, addr2, _, _, _, _, _} -> addr1 < addr2 end)

    # Assert that they're all in order of ascending address
    assert_ascending_contiguous_order(fields)

    # query for the entire data block
    [{_, _, addr, _, _, _, _, _} | _rest] = fields
    num_registers = Enum.reduce(fields, 0, fn {_, _, _, registers, _, _, _, _}, acc -> acc + registers end)

    fields = fields
    |> Enum.map(fn {name, type, _, num_registers, _, _, _, enum_map} -> {name, type, num_registers, enum_map} end)

    quote do
      @doc "#{unquote(desc)}"
      @spec unquote(name)(pid, integer) :: {:ok, map()} | {:error, term()}
      def unquote(name)(pid, slave_id \\ 1) do
        ExModbus.Runtime.get_fields(pid, slave_id, unquote(addr - 1), unquote(num_registers), unquote(Macro.escape(fields)))
      end
    end
  end

  defp find_by_name!(fields, name) do
    case Enum.find(fields, &(do_find_by_name!(&1, name))) do
      nil ->
        Logger.error inspect([name, fields])
        raise ArgumentError, "Not all group fields available in single fields list"
      field -> field
    end
  end
  defp do_find_by_name!({name, _, _, _, _, _, _, _}, name), do: true
  defp do_find_by_name!(_, _), do: false

  def assert_ascending_contiguous_order(fields) do
    fields
    |> Enum.chunk(2, 1)
    |> Enum.each(&assert_contiguous!/1)
  end

  defp assert_contiguous!([{_, _, addr1, bytes1, _, _, _, _}, {_, _, addr2, _, _, _, _, _}]) do
    case addr1 + bytes1 == addr2 do
      true -> true
      false -> raise ArgumentError, "Fields must be contiguous. #{addr1} #{bytes1} #{addr2}"
    end
  end

  def defgetter(name, type, addr, num_bytes, desc, units, enum_map) do
    quote do
      unquote(docs(desc, type, units, addr, num_bytes))
      @spec unquote(name)(pid, integer) :: {:ok, %{data: any(), transaction_id: integer(), unit_id: integer()}} |
                                           {:type_conversion_error, {any(), any()}} |
                                           {:enum_not_found_error, String.t}
      def unquote(name)(pid, slave_id \\ 1) do
        ExModbus.Runtime.get_field(pid, slave_id, unquote(addr-1), unquote(num_bytes), unquote(type), unquote(Macro.escape(enum_map)))
      end
    end
  end

  def defsetter(name, type, addr, num_bytes, desc, units, enum_map) do
    quote do
      unquote(docs(desc, type, units, addr, num_bytes))
      @spec unquote(name)(pid, integer, any) :: :ok
      def unquote(name)(pid, slave_id, data) do
        ExModbus.Runtime.set_field(pid, slave_id, data, unquote(addr - 1), unquote(type), unquote(Macro.escape(enum_map)))
      end
    end
  end

  def docs(desc, type, units, addr, num_bytes) do
    quote do
      @doc """
      #{unquote(desc)}
      * Field Type: #{unquote(inspect type)}
      * Units: #{unquote(inspect units)}
      * Addr: #{unquote(inspect addr)}
      * Num Bytes: #{unquote(inspect num_bytes)}
      """
    end
  end
end

