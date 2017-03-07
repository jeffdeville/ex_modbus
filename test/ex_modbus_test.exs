defmodule ExModbus.TestDevice do
  use ExModbus
  field :manufacturer,   :string32, 40005, 16, :r,  "(Mn Units: SF:) Manufacturer Range: Fronius"
  field :device_address, :uint16,   40069,  1, :r,  "(DA Units: SF:) Modbus Device Address Range: 1-247"
  field :a_sf,           :sunssf,   40076,  2, :r,  "AC current scale factor"
  field :var,            :int16,    40090,  1, :r,  "(VAr) Reactive power"
  field :unk_type,       :unknown,  40098,  1, :r,  "Unknown type"
  field :enum_test,      :enum16,   40099,  1, :r,  "Enum Test", %{1 => "OFF", 2 => "On"}
  field :enum_test_fail, :enum16,   40100,  1, :r,  "Enum Test", %{1 => "OFF", 2 => "On"}
  field :conn_win_tms,   :uint16,   40230,  1, :rw, "Time window for connect/disconnect (0-300 seconds)"
end

defmodule ExModbus.FakeClient do
  use GenServer

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end
  def handle_call({:read_holding_registers, %{unit_id: unit_id, start_address: address, data: count}}, from, _) do
    response = {:ok,
      %{
        data: {:read_holding_registers, do_handle_call(address, count)},
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

  def handle_call({:write_multiple_registers, %{unit_id: unit_id, start_address: address, data: data}}, from, _) do
    response = {:ok,
      %{
        data: {:write_multiple_registers, do_handle_call(address, data)},
        transaction_id: 1,
        unit_id: unit_id
      }
    }
    {:reply, response, from}
  end

end

defmodule ExModbusTest do
  use ExUnit.Case
  alias ExModbus.{Client,TestDevice}

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


  # describe "reading data, function 03" do
  #   setup do
  #     {:ok, pid} = case System.get_env("SLAVE_HOST") do
  #       nil ->
  #         {:ok, [{ip, _, _} | _rest]} = :inet.getif()
  #         ExModbus.Client.start_link(%{ip: ip, port: 5002})
  #       host -> ExModbus.Client.start_link(%{host: host, port: 5002})
  #     end
  #     {:ok, %{pid: pid, slave_id: 1}}
  #   end


  #   test "can read type: string16", %{pid: pid, slave_id: slave_id} do
  #     assert {:ok, %{data: "1.2.3"}} = FroniusInt.version(pid, slave_id)
  #   end

  #   test "can read type: string32", %{pid: pid, slave_id: slave_id} do
  #     assert {:ok, %{data: "SunSpecText"}} = FroniusInt.manufacturer(pid, slave_id)
  #   end

  #   test "can read type: uint16", %{pid: pid, slave_id: slave_id} do
  #     assert {:ok, %{data: 1}} = FroniusInt.device_address(pid, slave_id)
  #   end

  #   test "can read type: uint32", %{pid: pid, slave_id: slave_id} do
  #     assert {:ok, %{data: 0}} = FroniusInt.evt1(pid, slave_id)
  #   end

  #   test "can read type: float32", %{pid: pid, slave_id: slave_id} do
  #     assert {:ok, %{data: 549}} = FroniusInt.ac(pid, slave_id)
  #     assert {:ok, %{data: 2}} = FroniusInt.a_sf(pid, slave_id)
  #   end

  #   test "can read type: enum16", %{pid: pid, slave_id: slave_id} do
  #     assert {:enum_not_found_error, "[nil, :off, :sleeping, :starting, :mppt, :throttled, :shutting_down, :fault, :standby, :no_businit, :no_comm_inv, :sn_overcurrent, :bootload, :afci] either has no member 0, or it is out of range"} = FroniusInt.st_vnd(pid, slave_id)
  #   end

  #   test "can write", %{pid: pid, slave_id: slave_id} do
  #     IO.puts inspect FroniusInt.wmax_lim_pct(pid, slave_id)
  #     assert {:ok, %{data: 1}} = FroniusInt.wmax_lim_pct(pid, slave_id)
  #     FroniusInt.set_wmax_lim_pct(pid, slave_id, 50)
  #   end
  # end

  # describe "to_bytes\2" do
  #   test "can map int16" do
  #     assert ExModbus.to_bytes(10, :int16) == <<0, 10>>
  #     assert ExModbus.to_bytes(-10, :int16) == <<255, 246>>
  #   end

  #   test "can map uint16" do
  #     assert ExModbus.to_bytes(10, :uint16) == <<0, 10>>
  #   end

  #   test "can map enum16" do
  #     assert ExModbus.to_bytes(1, :enum16, %{disabled: 0, enabled: 1}) == <<0, 1>>
  #     assert ExModbus.to_bytes(0, :enum16, %{disabled: 0, enabled: 1}) == <<0, 0>>
  #     assert ExModbus.to_bytes(:enabled, :enum16, %{disabled: 0, enabled: 1}) == <<0, 1>>
  #     assert ExModbus.to_bytes(:disabled, :enum16, %{disabled: 0, enabled: 1}) == <<0, 0>>
  #   end
  # end
end
