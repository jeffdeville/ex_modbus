defmodule ExModbus.TestDevice do
  use ExModbus
  field :manufacturer,   :string,   40005, 16, :r,  "(Mn Units: SF:) Manufacturer Range: Fronius"
  field :device_address, :uint16,   40069,  1, :r,  "(DA Units: SF:) Modbus Device Address Range: 1-247"
  field :a_sf,           :sunssf,   40076,  2, :r,  "AC current scale factor", units: "SF"
  field :var,            :int16,    40090,  1, :r,  "(VAr) Reactive power", units: "Var"
  field :unk_type,       :unknown,  40098,  1, :r,  "Unknown type", units: "googles"
  field :enum_test,      :enum16,   40099,  1, :r,  "Enum Test", enum_map: %{1 => "OFF", 2 => "On"}
  field :enum_test_fail, :enum16,   40100,  1, :r,  "Enum Test", enum_map: %{1 => "OFF", 2 => "On"}
  field :conn_win_tms,   :uint16,   40230,  1, :rw, "Time window for connect/disconnect (0-300 seconds)", units: "S"
  field :outpfset_ena,   :enum16,   40240,  1, :rw, "set a power factor", enum_map: %{0 => "DISABLED", 1 => "ENABLED"}
end

defmodule ExModbus.SunSpecCommon do
  @doc """
  This simplest possible SunSpec device. Implements Model 1
  """
  use ExModbus
  field :manufacturer,    :string, 40005, 16, :r,  "Well known value registered with SunSpec for compliance"
  field :model,           :string, 40021, 16, :r,  "Manufacturer specific value (32 chars)"
  field :options,         :string, 40037,  8, :r,  "Manufacturer specific value (16 chars)"
  field :version,         :string, 40045,  8, :r,  "Manufacturer specific value (16 chars)"
  field :serial_number,   :string, 40053, 16, :r,  "Manufacturer specific value (32 chars)"
  field :device_address,  :uint16, 40069,  1, :rw, "Modbus device address"

  field_group :common,     [:manufacturer, :model, :options, :version, :serial_number, :device_address]
end

defmodule ExModbus.SunSpecInverter do
  use ExModbus

  field :amps, :float32, 40072, 2, :r, "AC Current"
  field :amps_phasea, :float32, 40074, 2, :r, "Phase A Current"
  field :amps_phaseb, :float32, 40076, 2, :r, "Phase B Current"
  field :amps_phasec, :float32, 40078, 2, :r, "Phase C Current"
  field :phase_voltage_ab, :float32, 40080, 2, :r, "Phase Voltage AB"
  field :phase_voltage_bc, :float32, 40082, 2, :r, "Phase Voltage BC"
  field :phase_voltage_ca, :float32, 40084, 2, :r, "Phase Voltage CA"
  field :phase_voltage_an, :float32, 40086, 2, :r, "Phase Voltage AN"
  field :phase_voltage_bn, :float32, 40088, 2, :r, "Phase Voltage BN"
  field :phase_voltage_cn, :float32, 40090, 2, :r, "Phase Voltage CN"
  field :watts, :float32, 40092, 2, :r, "AC Power"
  field :hz, :float32, 40094, 2, :r, "Line Frequency"
  field :va, :float32, 40096, 2, :r, "AC Apparent Power"
  field :var, :float32, 40098, 2, :r, "AC Reactive Power"
  field :pf, :float32, 40100, 2, :r, "AC Power Factor"
  field :watthours, :float32, 40102, 2, :r, "AC Energy"
  field :dc_amps, :float32, 40104, 2, :r, "DC Current"
  field :dc_voltage, :float32, 40106, 2, :r, "DC Voltage"
  field :dc_watts, :float32, 40108, 2, :r, "DC Power"
  field :cabinet_temperature, :float32, 40110, 2, :r, "Cabinet Temperature"
  field :heat_sink_temperature, :float32, 40112, 2, :r, "Heat Sink Temperature"
  field :transformer_temperature, :float32, 40114, 2, :r, "Transformer Temperature"
  field :other_temperature, :float32, 40116, 2, :r, "Other Temperature"
  field :operating_state, :enum16, 40118, 1, :r, "Enumerated value.  Operating state"
  field :vendor_operating_state, :enum16, 40119, 1, :r, "Vendor specific operating state code"
  field :event1, :bitfield32, 40120, 2, :r, "Bitmask value. Event fields"
  field :event_bitfield_2, :bitfield32, 40122, 2, :r, "Reserved for future use"
  field :vendor_event_bitfield_1, :bitfield32, 40124, 2, :r, "Vendor defined events"
  field :vendor_event_bitfield_2, :bitfield32, 40126, 2, :r, "Vendor defined events"
  field :vendor_event_bitfield_3, :bitfield32, 40128, 2, :r, "Vendor defined events"
  field :vendor_event_bitfield_4, :bitfield32, 40130, 2, :r, "Vendor defined events"

  field_group :inverter_single_phase_float, [:amps, :amps_phasea, :amps_phaseb, :amps_phasec, :phase_voltage_ab,
    :phase_voltage_bc, :phase_voltage_ca, :phase_voltage_an, :phase_voltage_bn, :phase_voltage_cn, :watts, :hz,
    :va, :var, :pf, :watthours, :dc_amps, :dc_voltage, :dc_watts, :cabinet_temperature, :heat_sink_temperature,
    :transformer_temperature, :other_temperature, :operating_state, :vendor_operating_state, :event1,
    :event_bitfield_2, :vendor_event_bitfield_1, :vendor_event_bitfield_2, :vendor_event_bitfield_3,
    :vendor_event_bitfield_4]
end

defmodule ExModbus.FakeClient do
  use GenServer

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def handle_call({action, %{unit_id: unit_id, start_address: address, data: count}}, from, _) do
    response = {:ok,
      %{
        data: {action, do_handle_call(address, count)},
        transaction_id: 1,
        unit_id: unit_id
      }
    }
    {:reply, response, from}
  end
  def do_handle_call(40004, 16), do: 'Fronius' ++ [0, 0, 0, 0, 0, 0, 0, 0, 0] |> :binary.list_to_bin
  def do_handle_call(40068, 1), do: <<38::unsigned-integer-size(16)>>
  def do_handle_call(40075, 2), do: <<-1::signed-integer-size(32)>>
  def do_handle_call(40089, 1), do: <<-23::signed-integer-size(16)>>
  # Note: The type return here does not matter.
  def do_handle_call(40097, 1), do: <<-1::signed-integer-size(16)>>
  def do_handle_call(40098, 1), do: <<1::unsigned-integer-size(16)>>
  def do_handle_call(40099, 1), do: <<99::unsigned-integer-size(16)>>
  def do_handle_call(40229, 1), do: <<1::unsigned-integer-size(16)>>
  def do_handle_call(40229, <<0, 13>>), do: <<13::unsigned-integer-size(16)>>
  def do_handle_call(40239, <<0, 1>>), do: <<1::unsigned-integer-size(16)>>
  def do_handle_call(40239, <<0, 0>>), do: <<0::unsigned-integer-size(16)>>
  def do_handle_call(40004, 65), do: File.read!("test/support/common.bin")
  def do_handle_call(40071, 60), do: File.read!("test/support/inverter_single_phase_float.bin")
end

defmodule ExModbusTest do
  use ExUnit.Case
  alias ExModbus.TestDevice
  alias ExModbus.SunSpecCommon
  alias ExModbus.SunSpecInverter

  describe "macro funcs" do
    setup do
      {:ok, pid} = ExModbus.FakeClient.start_link(%{}, [])
      {:ok, %{pid: pid}}
    end

    test "reads all valid types strings", %{pid: pid} do
      # Strings
      assert {:ok, %{data: "Fronius", slave_id: 1}} = TestDevice.manufacturer(pid, 1)
      assert {:ok, %{data: "Fronius", slave_id: 2}} = TestDevice.manufacturer(pid, 2)

      # Integers
      assert {:ok, %{data: 38}} = TestDevice.device_address pid, 1
      assert {:ok, %{data: -23}} = TestDevice.var pid, 1
      assert {:ok, %{data: 1}} = TestDevice.conn_win_tms pid, 1

      # SSF
      assert {:ok, %{data: -1}} = TestDevice.a_sf pid, 1

      # Enum
      assert {:ok, %{data: "OFF"}} = TestDevice.enum_test pid, 1
    end

    test "type_conversion_error", %{pid: pid} do
      assert {:type_conversion_error, {<<255, 255>>, :unknown}} = TestDevice.unk_type pid, 1
    end

    test "enum_not_found_error", %{pid: pid} do
      assert {:enum_not_found_error, "%{1 => \"OFF\", 2 => \"On\"} either has no member 99, or it is out of range"} = TestDevice.enum_test_fail pid, 1
    end

    test "writing data", %{pid: pid} do
      assert {:ok, %{data: <<0, 13>>}} = TestDevice.set_conn_win_tms(pid, 1, 13)
    end

    test "writing to an enum type using either the enumeration or the integer value", %{pid: pid} do
      assert {:ok, %{data: <<0, 1>>}} = TestDevice.set_outpfset_ena(pid, 1, "ENABLED")
      assert {:ok, %{data: <<0, 0>>}} = TestDevice.set_outpfset_ena(pid, 1, 0)
    end

    test "reads common field groupings", %{pid: pid} do
      assert {:ok, %{
        data: %{
          manufacturer: manufacturer,
          model: model,
          options: options,
          version: version,
          serial_number: serial_number,
          device_address: device_address
        }, transaction_id: 1, slave_id: 1
      }} = SunSpecCommon.common(pid, 1)
      assert manufacturer == "Fronius"
      assert model == "Primo 3.8-1 208-240"
      assert options == "3.5.3-1"
      assert version == "0.3.8.2"
      assert serial_number == "27391000745290196"
      assert device_address == 1
    end

    test "reads inverter field groupings", %{pid: pid} do
      assert {:ok, %{
        data: %{
          amps: amps,
          amps_phasea: amps_phasea,
          amps_phaseb: amps_phaseb,
          amps_phasec: amps_phasec,
          phase_voltage_ab: phase_voltage_ab,
          phase_voltage_bc: phase_voltage_bc,
          phase_voltage_ca: phase_voltage_ca,
          phase_voltage_an: phase_voltage_an,
          phase_voltage_bn: phase_voltage_bn,
          phase_voltage_cn: phase_voltage_cn,
          watts: watts,
          hz: hz,
          va: va,
          var: var,
          pf: pf,
          watthours: watthours,
          dc_amps: dc_amps,
          dc_voltage: dc_voltage,
          dc_watts: dc_watts,
          cabinet_temperature: cabinet_temperature,
          heat_sink_temperature: heat_sink_temperature,
          transformer_temperature: transformer_temperature,
          other_temperature: other_temperature,
          operating_state: operating_state,
          vendor_operating_state: vendor_operating_state,
          event1: event1,
          event_bitfield_2: event_bitfield_2,
          vendor_event_bitfield_1: vendor_event_bitfield_1,
          vendor_event_bitfield_2: vendor_event_bitfield_2,
          vendor_event_bitfield_3: vendor_event_bitfield_3,
          vendor_event_bitfield_4: vendor_event_bitfield_4
        }, transaction_id: 1, slave_id: 1
      }} = SunSpecInverter.inverter_single_phase_float(pid, 1)

      assert amps == 1.409999966621399
      assert amps_phasea == 1.409999966621399
      assert is_nil(amps_phaseb)
      assert is_nil(amps_phasec)
      assert is_nil(phase_voltage_ab)
      assert is_nil(phase_voltage_bc)
      assert is_nil(phase_voltage_ca)
      assert phase_voltage_an == 237.40000915527344
      assert is_nil(phase_voltage_bn)
      assert is_nil(phase_voltage_cn)
      assert watts == 314.0
      assert hz == 60.02000045776367
      assert va == 314.7014465332031
      assert var == 21.0
      assert pf == -99.77710723876953
      assert watthours == 746458.625
      assert dc_amps == 1.459999918937683
      assert dc_voltage == 128.3000030517578
      assert dc_watts == 187.3179931640625
      assert is_nil(cabinet_temperature)
      assert is_nil(heat_sink_temperature)
      assert is_nil(transformer_temperature)
      assert is_nil(other_temperature)
      assert operating_state == 4
      assert vendor_operating_state == 4
      assert event1 == 0
      assert event_bitfield_2 == 0
      assert vendor_event_bitfield_1 == 0
      assert vendor_event_bitfield_2 == 0
      assert vendor_event_bitfield_3 == 0
      assert vendor_event_bitfield_4 == 0
    end
  end
end
