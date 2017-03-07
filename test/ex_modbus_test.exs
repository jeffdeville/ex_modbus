defmodule ExModbus.TestDevice do
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
end

defmodule ExModbusTest do
  use ExUnit.Case
  alias ExModbus.TestDevice

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
  end
end
