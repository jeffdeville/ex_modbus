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

  describe "map_enum_value/2" do
    test "when no enum map" do
      assert map_enum_value(:uint32, %{}, "5") == {:ok, "5"}
      assert map_enum_value(:enum16, %{}, "5") == {:ok, "5"}
    end

    test "when enum exists, but value does not match" do
      enum_map = %{"missing" => "value"}
      assert map_enum_value(:enum16, enum_map, "no_match") == {:enum_not_found_error, "#{inspect enum_map} either has no member no_match, or it is out of range"}
    end

    test "when enum exists, and value matches" do
      enum_map = %{"value" => "enumeration match"}
      assert map_enum_value(:enum16, enum_map, "value") == {:ok, "enumeration match"}
    end

    test "when bitfields, map all values" do
      enum_map = %{0 => "CONNECTED", 1 => "AVAILABLE", 2 => "OPERATING", 3 => "TEST"}
      assert map_enum_value(:bitfield16, enum_map, 7) == {:ok, %{"CONNECTED" => true, "AVAILABLE" => true, "OPERATING" => true, "TEST" => false}}
    end
  end

  describe "deggroupgetter/3" do
    test "fields could not be found will raise" do
      assert_raise ArgumentError,
                   "Not all group fields available in single fields list",
                   fn -> defgroupgetter("name", [:fielda, :fieldb], []) end
    end

    test "raises if fields are not contiguous" do
      assert_raise ArgumentError,
                   "Fields must be contiguous. 40021 16 40045",
                   fn -> defgroupgetter(
                           "name",
                           [:serial_number, :version, :model, :manufacturer],
                           [{:manufacturer, :string, 40005, 16, :r, "Well known value registered with SunSpec for compliance", "", %{}},
                            {:model, :string, 40021, 16, :r, "Manufacturer specific value (32 chars)", "", %{}},
                            {:options, :string, 40037, 8, :r, "Manufacturer specific value (16 chars)", "", %{}},
                            {:version, :string, 40045, 8, :r, "Manufacturer specific value (16 chars)", "", %{}},
                            {:serial_number, :string, 40053, 16, :r, "Manufacturer specific value (32 chars)", "", %{}}]
                         )
                    end
    end

    test "all good so far" do
      assert fn ->
        defgroupgetter(
          "name",
          [:serial_number, :version, :options, :model, :manufacturer],
          [{:manufacturer, :string, 40005, 16, :r, "Well known value registered with SunSpec for compliance", "", %{}},
           {:model, :string, 40021, 16, :r, "Manufacturer specific value (32 chars)", "", %{}},
           {:options, :string, 40037, 8, :r, "Manufacturer specific value (16 chars)", "", %{}},
           {:version, :string, 40045, 8, :r, "Manufacturer specific value (16 chars)", "", %{}},
           {:serial_number, :string, 40053, 16, :r, "Manufacturer specific value (32 chars)", "", %{}}]
        )
      end
    end
  end
end
