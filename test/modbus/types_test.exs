defmodule ExModbus.TypesTest do
  use ExUnit.Case
  import ExModbus.Types

  test "convert_type/2 - :bitfield32" do
    assert convert_type(<<01010101010101010101010101010101>>, :bitfield32) == {:ok, 43981}
  end

  test "convert_type/2 - :bitfield16" do

  end

  test "convert_type/2 - :int16" do

  end

  test "convert_type/2 - :enum16" do

  end

  test "convert_type/2 - :uint16" do

  end

  test "convert_type/2 - :uint32" do

  end

  test "convert_type/2 - :sunssf with 16" do

  end

  test "convert_type/2 - :sunssf with 32" do

  end

  test "convert_type/2 - :float32" do

  end

  test "convert_type/2 - :string32" do

  end

  test "convert_type/2 - :string16" do

  end

end
