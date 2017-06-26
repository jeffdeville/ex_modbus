defmodule ExModbus.MacrosTest do
  use ExUnit.Case
  import ExModbus.Macros

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
