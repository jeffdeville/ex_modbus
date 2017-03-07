defmodule ExModbus.Fronius do
  use ExModbus
  field :manufacturer,   :string32, 40005, 16, :r,  "(Mn Units: SF:) Manufacturer Range: Fronius"
  field :device_address, :uint16,   40069,  1, :r,  "(DA Units: SF:) Modbus Device Address Range: 1-247"
  field :a_sf,           :sunssf,   40076,  2, :r,  "AC current scale factor", units: "SF"
  field :var,            :int16,    40090,  1, :r,  "(VAr) Reactive power", units: "Var"
  field :unk_type,       :unknown,  40098,  1, :r,  "Unknown type", units: "googles"
  field :enum_test,      :enum16,   40099,  1, :r,  "Enum Test", enum_map: %{1 => "OFF", 2 => "On"}
  field :enum_test_fail, :enum16,   40100,  1, :r,  "Enum Test", enum_map: %{1 => "OFF", 2 => "On"}
  field :conn_win_tms,   :uint16,   40230,  1, :rw, "Time window for connect/disconnect (0-300 seconds)", units: "S"
end
