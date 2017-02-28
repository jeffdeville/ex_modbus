defmodule ExModbus.Types do
  def convert_type(<<bitfield::unsigned-integer-size(32)>>, :bitfield32), do: {:ok, bitfield}
  def convert_type(<<bitfield::unsigned-integer-size(16)>>, :bitfield16), do: {:ok, bitfield}
  def convert_type(<<int::signed-integer-size(16)>>,        :int16),      do: {:ok, int}
  def convert_type(<<uint::unsigned-integer-size(16)>>,     :enum16),     do: {:ok, uint}
  def convert_type(<<uint::unsigned-integer-size(16)>>,     :uint16),     do: {:ok, uint}
  def convert_type(<<uint::unsigned-integer-size(32)>>,     :uint32),     do: {:ok, uint}
  def convert_type(<<sf::signed-integer-size(16)>>,         :sunssf),     do: {:ok, sf}
  def convert_type(<<flt::float-size(32)>>,                 :float32),    do: {:ok, flt}
  def convert_type(data, :string32), do: convert_type(data, :string)
  def convert_type(data, :string16), do: convert_type(data, :string)
  def convert_type(data, <<"String", _size::binary>>), do: convert_type(data, :string)
  def convert_type(data, :string) do
    res = data
    |> :binary.bin_to_list
    |> Enum.filter(fn(byte) -> byte != 0 end)
    |> to_string

    {:ok, res}
  end
  def convert_type(data, type), do: {:type_conversion_error, {data, type}}
end
