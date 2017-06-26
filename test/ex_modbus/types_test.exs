defmodule ExModbus.TypesTest do
  use ExUnit.Case
  import ExModbus.Types

  describe "to_binary/3" do
    test "int16" do
      assert to_binary(24, :int16, nil) == {:ok, <<0, 24>>}
      assert to_binary(9999, :int16, nil) == {:ok, <<39, 15>>}
      assert to_binary(-9999, :int16, nil) == {:ok, <<216, 241>>}
    end

    test "uint16" do
      assert to_binary(24, :uint16, nil) == {:ok, <<0, 24>>}
      assert to_binary(9999, :uint16, nil) == {:ok, <<39, 15>>}
      assert {:invalid_data_type, _} = to_binary(-9999, :uint16, nil)
    end

    test "enum16" do
      enum_map = %{0 => "DISABLED", 1 => "ENABLED"}
      assert {:ok, <<0, 0>>} = to_binary(0, :enum16, enum_map)
      assert {:ok, <<0, 1>>} = to_binary(1, :enum16, enum_map)
      assert {:ok, <<0, 0>>} = to_binary("DISABLED", :enum16, enum_map)
      assert {:ok, <<0, 1>>} = to_binary("ENABLED", :enum16, enum_map)
      assert {:invalid_enum_value, _} = to_binary("INVALID", :enum16, enum_map)
      assert {:invalid_enum_value, _} = to_binary(2, :enum16, enum_map)
    end
  end

  describe "bitfield_to_enum/2" do
    test "when no enum map" do
      assert bitfield_to_enum(:uint32, %{}, "5") == {:ok, "5"}
      assert bitfield_to_enum(:enum16, %{}, "5") == {:ok, "5"}
    end

    test "when enum exists, but value does not match" do
      enum_map = %{"missing" => "value"}
      assert bitfield_to_enum(:enum16, enum_map, "no_match") == {:enum_not_found_error, "#{inspect enum_map} either has no member no_match, or it is out of range"}
    end

    test "when enum exists, and value matches" do
      enum_map = %{"value" => "enumeration match"}
      assert bitfield_to_enum(:enum16, enum_map, "value") == {:ok, "enumeration match"}
    end

    test "when bitfields, map all values" do
      enum_map = %{0 => "CONNECTED", 1 => "AVAILABLE", 2 => "OPERATING", 3 => "TEST"}
      assert bitfield_to_enum(:bitfield16, enum_map, 7) == {:ok, %{"CONNECTED" => true, "AVAILABLE" => true, "OPERATING" => true, "TEST" => false}}
    end
  end
end
