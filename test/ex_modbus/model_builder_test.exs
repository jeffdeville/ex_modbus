defmodule ExModbus.ModelBuilderTest do
  use ExUnit.Case
  import ExModbus.ModelBuilder

  describe "to_bytes/2" do
    test "int16" do
      assert to_bytes(24, :int16, nil) == {:ok, <<0, 24>>}
      assert to_bytes(9999, :int16, nil) == {:ok, <<39, 15>>}
      assert to_bytes(-9999, :int16, nil) == {:ok, <<216, 241>>}
    end

    test "uint16" do
      assert to_bytes(24, :uint16, nil) == {:ok, <<0, 24>>}
      assert to_bytes(9999, :uint16, nil) == {:ok, <<39, 15>>}
      assert {:invalid_data_type, _} = to_bytes(-9999, :uint16, nil)
    end

    test "enum16" do
      enum_map = %{0 => "DISABLED", 1 => "ENABLED"}
      assert {:ok, <<0, 0>>} = to_bytes(0, :enum16, enum_map)
      assert {:ok, <<0, 1>>} = to_bytes(1, :enum16, enum_map)
      assert {:ok, <<0, 0>>} = to_bytes("DISABLED", :enum16, enum_map)
      assert {:ok, <<0, 1>>} = to_bytes("ENABLED", :enum16, enum_map)
      assert {:invalid_enum_value, _} = to_bytes("INVALID", :enum16, enum_map)
      assert {:invalid_enum_value, _} = to_bytes(2, :enum16, enum_map)
    end

  end
end
