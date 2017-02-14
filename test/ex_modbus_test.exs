defmodule ExModbus.TestInverter do
  use ExModbus
  # C001, Common
  field :manufacturer,   :string32, 40005, 16, :r, "(Mn Units:  SF: ) Manufacturer - Range: Fronius"
  field :model,          :string32, 40021, 16, :r, "(Md Units:  SF: ) Device model - Range: z. B. IG+150V [3p]"
  field :options,        :string16, 40037,  8, :r, "(Opt Units:  SF: ) Options - Range: Firmware version of Datamanager"
  field :version,        :string16, 40045,  8, :r, "(Vr Units:  SF: ) SW version of inverter - Range:"
  field :serial,         :string32, 40053, 16, :r, "(SN Units:  SF: ) Serialnumber of the inverter - Range:"
  field :device_address, :uint16,   40069,  1, :r, "(DA Units:  SF: ) Modbus Device Address - Range: 1-247"

  # Inverter Model - Float
  field :ac,                :float32, 40072, 2, :r,  "(A) AC total current value"
  field :aph_a,             :float32, 40074, 2, :r,  "(A) AC phase A current val- ue"
  field :aph_b,             :float32, 40076, 2, :r,  "(A) AC phase B current val- ue"
  field :aph_c,             :float32, 40078, 2, :r,  "(A) AC phase C current val- ue"
  field :ppv_ph_ab,         :float32, 40080, 2, :r,  "(V) AC voltage phase AB value"
  field :ppv_ph_bc,         :float32, 40082, 2, :r,  "(V) AC voltage phase BC value"
  field :ppv_ph_ca,         :float32, 40084, 2, :r,  "(V) AC voltage phase CA value"
  field :ph_vph_a,          :float32, 40086, 2, :r,  "(V) AC voltage phase-A-to- neutral value"
  field :ph_vph_b,          :float32, 40088, 2, :r,  "(V) AC voltage phase-B-to- neutral value"
  field :ph_vph_c,          :float32, 40090, 2, :r,  "(V) AC voltage phase-C-to- neutral value"
  field :w,                 :float32, 40092, 2, :r,  "(W) AC power value"
  field :hz,                :float32, 40094, 2, :r,  "(Hz) AC frequency value"
  field :va,                :float32, 40096, 2, :r,  "(VA) Apparent power"
  field :v_ar,              :float32, 40098, 2, :r,  "(VAr) Reactive power"
  field :pf,                :float32, 40100, 2, :r,  "(%) Power factor"
  field :wh,                :float32, 40102, 2, :r,  "(Wh) AC lifetime energy pro- duction"
  field :dca,               :float32, 40104, 2, :r,  "(A) DC current value - DC current only if one MPPT available; with multiple MPPT 'not implemented'"
  field :dcv,               :float32, 40106, 2, :r, "V DC voltage value DC voltage only if one MPPT avail- able; with multiple MPPT “not implement- ed”"
  field :dcw,               :float32, 40108, 2, :r, "W DC power value Total DC power of all available MPPT"
  field :temp_cabinet,      :float32, 40110, 2, :r, "°C Cabinet temperature"
  field :temp_heat_sink,    :float32, 40112, 2, :r, "°C Coolant or heat sink temperature"
  field :temp_transformer,  :float32, 40114, 2, :r, "°C Transformer tempera- ture"
  field :temp_other,        :float32, 40116, 2, :r, "°C Other temperature"
  # SunSpec State Codes
  # Name                  Value  Description
  # I_STATUS_OFF            1    Inverter is off
  # I_STATUS_SLEEPING       2    Auto shutdown
  # I_STATUS_STARTING       3    Inverter starting
  # I_STATUS_MPPT           4    Inverter working normally
  # I_STATUS_THROTTLED      5    Power reduction active
  # I_STATUS_SHUTTING_DOWN  6    Inverter shutting down
  # I_STATUS_FAULT          7    One or more faults present, see St*or Evt* register
  # I_STATUS_STANDBY        8    Standby
  field :st,                :enum16,  40118, 1, :r, "Enumerated Operating state (see SunSpec State Codes)",
  fn
    0 -> nil
    1 -> :off
    2 -> :sleeping
    3 -> :starting
    4 -> :mppt
    5 -> :throttled
    6 -> :shutting_down
    7 -> :fault
    8 -> :standby
  end

  # Fronius State Codes
  # Name                  Value Description
  # I_STATUS_OFF            1   Inverter is off
  # I_STATUS_SLEEPING       2   Auto shutdown
  # I_STATUS_STARTING       3   Inverter starting
  # I_STATUS_MPPT           4   Inverter working normally
  # I_STATUS_THROTTLED      5   Power reduction active
  # I_STATUS_SHUTTING_DOWN  6   Inverter shutting down
  # I_STATUS_FAULT          7   One or more faults present, see St*or Evt* register
  # I_STATUS_STANDBY        8   Standby
  # I_STATUS_NO_BUSINIT     9   No SolarNet communication
  # I_STATUS_NO_COMM_INV    10  No communication with inverter possible
  # I_STATUS_SN_OVERCURRENT 11  Overcurrent detected on SolarNet plug
  # I_STATUS_BOOTLOAD       12  Inverter is currently being updated
  # I_STATUS_AFCI           13  AFCI event arcdetection
  field :st_vnd, :enum16, 40119, 1, :r, "Enumerated Vendor defined operating state (See Fronius State Codes))",
    fn
      0  -> nil
      1  -> :off
      2  -> :auto_shutdown
      3  -> :starting
      4  -> :normal
      5  -> :power_reduction_active
      6  -> :shutting_down
      7  -> :fault
      8  -> :standby
      9  -> :no_solarnet
      10 -> :no_inverter_comms
      11 -> :overcurren
      12 -> :updating
      13 -> :arcdetection
    end
  field :evt1,              :uint32,  40120, 2, :r, "Bit field Event flags (bits 0–31) (custom - can be downloaded from Fronius website)"
  field :evt2,              :uint32,  40122, 2, :r, "Bit field Event flags (bits 32–63) (custom - can be downloaded from Fronius website)"
  field :evt_vnd1,          :uint32,  40124, 2, :r, "Bit field Vendor defined event flags (bits 0–31) (custom - can be downloaded from Fronius website)"
  field :evt_vnd2,          :uint32,  40126, 2, :r, "Bit field Vendor defined event flags (bits 32–63) (custom - can be downloaded from Fronius website)"
  field :evt_vnd3,          :uint32,  40128, 2, :r, "Bit field Vendor defined event flags (bits 64–95) (custom - can be downloaded from Fronius website)"
  field :evt_vnd4,          :uint32,  40130, 2, :r, "Bit field Vendor defined event flags (bits 96–127) (custom - can be downloaded from Fronius website)"

  # Left off on Nameplate Model (IC123)

end

defmodule ExModbusTest do
  use ExUnit.Case
  alias ExModbus.TestInverter

  describe "reading data, function 03" do
    setup do
      {:ok, pid} = ExModbus.Client.start_link(%{ip: {10, 0, 1, 3}})
      {:ok, %{pid: pid, slave_id: 1}}
    end

    test "can read type: string16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: "1.2.3"}} = TestInverter.version(pid, slave_id)
    end

    test "can read type: string32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: "SunSpecText"}} = TestInverter.manufacturer(pid, slave_id)
    end

    test "can read type: uint16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 1}} = TestInverter.device_address(pid, slave_id)
    end

    test "can read type: uint32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 0}} = TestInverter.evt1(pid, slave_id)
    end

    test "can read type: float32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 1.2122900943140371e-37}} = TestInverter.ac(pid, slave_id)
    end

    test "can read type: enum16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: nil}} = TestInverter.st_vnd(pid, slave_id)
    end

  end
end
