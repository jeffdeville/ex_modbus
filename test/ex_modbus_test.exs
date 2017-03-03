defmodule ExModbusTest do
  use ExUnit.Case
  alias ExModbus.Profiles.FroniusInt

  describe "reading data, function 03" do
    setup do
      {:ok, pid} = case System.get_env("SLAVE_HOST") do
        nil ->
          {:ok, [{ip, _, _} | _rest]} = :inet.getif()
          ExModbus.Client.start_link(%{ip: ip, port: 5002})
        host -> ExModbus.Client.start_link(%{host: host, port: 5002})
      end
      {:ok, %{pid: pid, slave_id: 1}}
    end

    test "can read type: string16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: "1.2.3"}} = FroniusInt.version(pid, slave_id)
    end

    test "can read type: string32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: "SunSpecText"}} = FroniusInt.manufacturer(pid, slave_id)
    end

    test "can read type: uint16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 1}} = FroniusInt.device_address(pid, slave_id)
    end

    test "can read type: uint32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 0}} = FroniusInt.evt1(pid, slave_id)
    end

    test "can read type: float32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 549}} = FroniusInt.ac(pid, slave_id)
      assert {:ok, %{data: 2}} = FroniusInt.a_sf(pid, slave_id)
    end

    test "can read type: enum16", %{pid: pid, slave_id: slave_id} do
      assert {:enum_not_found_error, "[nil, :off, :sleeping, :starting, :mppt, :throttled, :shutting_down, :fault, :standby, :no_businit, :no_comm_inv, :sn_overcurrent, :bootload, :afci] either has no member 0, or it is out of range"} = FroniusInt.st_vnd(pid, slave_id)
    end

    test "can write", %{pid: pid, slave_id: slave_id} do
      IO.puts inspect FroniusInt.wmax_lim_pct(pid, slave_id)
      assert {:ok, %{data: 1}} = FroniusInt.wmax_lim_pct(pid, slave_id)
      FroniusInt.set_wmax_lim_pct(pid, slave_id, 50)
    end
  end

  describe "to_bytes\2" do
    test "can map int16" do
      assert ExModbus.to_bytes(10, :int16) == <<0, 10>>
      assert ExModbus.to_bytes(-10, :int16) == <<255, 246>>
    end

    test "can map uint16" do
      assert ExModbus.to_bytes(10, :uint16) == <<0, 10>>
    end

    test "can map enum16" do
      assert ExModbus.to_bytes(1, :enum16, %{disabled: 0, enabled: 1}) == <<0, 1>>
      assert ExModbus.to_bytes(0, :enum16, %{disabled: 0, enabled: 1}) == <<0, 0>>
      assert ExModbus.to_bytes(:enabled, :enum16, %{disabled: 0, enabled: 1}) == <<0, 1>>
      assert ExModbus.to_bytes(:disabled, :enum16, %{disabled: 0, enabled: 1}) == <<0, 0>>
    end
  end
end
