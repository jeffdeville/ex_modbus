defmodule ExModbus.Types do
  use Bitwise

  def from_binary(<<127, 192, _rest::binary>>, _),                       do: {:ok, nil}
  def from_binary(<<bitfield::unsigned-integer-size(32)>>, :bitfield32), do: {:ok, bitfield}
  def from_binary(<<bitfield::unsigned-integer-size(16)>>, :bitfield16), do: {:ok, bitfield}
  def from_binary(<<int::signed-integer-size(16)>>,        :int16),      do: {:ok, int}
  def from_binary(<<uint::unsigned-integer-size(16)>>,     :enum16),     do: {:ok, uint}
  def from_binary(<<uint::unsigned-integer-size(16)>>,     :uint16),     do: {:ok, uint}
  def from_binary(<<uint::unsigned-integer-size(32)>>,     :uint32),     do: {:ok, uint}
  def from_binary(<<sf::signed-integer-size(16)>>,         :sunssf),     do: {:ok, sf}
  def from_binary(<<sf::signed-integer-size(32)>>,         :sunssf),     do: {:ok, sf}
  def from_binary(<<flt::float-size(32)>>,                 :float32),    do: {:ok, flt}
  def from_binary(<<uint::unsigned-integer-size(32)>>,     :acc32),      do: {:ok, uint}
  def from_binary(data, :string32), do: from_binary(data, :string)
  def from_binary(data, :string16), do: from_binary(data, :string)
  def from_binary(data, <<"String", _size::binary>>), do: from_binary(data, :string)
  def from_binary(data, :string) do
    res = data
    |> :binary.bin_to_list
    |> Enum.filter(fn(byte) -> byte != 0 end)
    |> to_string

    {:ok, res}
  end
  def from_binary(data, type), do: {:type_conversion_error, {data, type}}


  def to_binary(data, :int16, _), do: {:ok, <<data::signed-integer-size(16)>>}
  def to_binary(data, :uint16, _) when data >= 0, do: {:ok, <<data::unsigned-integer-size(16)>>}
  def to_binary(data, :uint16, _) when data < 0, do: {:invalid_data_type, "Data type is unsigned. No negative numbers"}
  def to_binary(data, :enum16, enum_map) when is_integer(data) do
    case Map.has_key?(enum_map, data) do
      true -> {:ok, <<data::unsigned-integer-size(16)>>}
      false -> {:invalid_enum_value, "#{data} is not a valid value in the enum: #{inspect enum_map}"}
    end
  end
  def to_binary(data, :enum16, enum_map) when is_binary(data) do
    flipped_map = enum_map |> flip_keys
    case Map.has_key?(flipped_map, data) do
      true -> {:ok, <<Map.fetch!(flipped_map, data)::unsigned-integer-size(16)>>}
      false -> {:invalid_enum_value, "#{data} is not a valid value in the enum: #{inspect flipped_map}"}
    end
  end

  defp flip_keys(map), do: Enum.reduce(map, %{}, fn {k, v}, acc -> Map.put(acc, v, k) end)

  def bitfield_to_enum(_, %{} = empty_map, value) when empty_map == %{}, do: {:ok, value}
  def bitfield_to_enum(:enum16, enum_map, value) do
    case Map.get(enum_map, value) do
      nil -> {:enum_not_found_error, "#{inspect enum_map} either has no member #{value}, or it is out of range"}
      enum_val -> {:ok, enum_val}
    end
  end
  def bitfield_to_enum(bitfield, enum_map, value) when bitfield in [:bitfield16, :bitfield32] do
    result = enum_map
      |> Enum.map(fn {index, enum_title} ->
        pow_of_2 = (round(:math.pow(2, index + 1)) - 1)
        is_match = (value &&& pow_of_2) == pow_of_2
        {enum_title, is_match}
      end)
      |> Enum.into(%{})
    {:ok, result}
  end

  def size_in_bytes(_type, num_registers) when is_number(num_registers), do: num_registers * 2
  def size_in_bytes(type, num_registers) when is_nil(num_registers) and is_atom(type),
    do: size_in_bytes(Atom.to_string(type))
  def size_in_bytes(type) when is_binary(type) do
    case Regex.run(~r{/d+}, type) do
      nil -> raise ArgumentError, "Unable to get size of type: #{type}"
      [size] -> String.to_integer(size) / 8
    end
  end
end
