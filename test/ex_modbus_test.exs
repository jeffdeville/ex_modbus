defmodule ExModbusTest do
  use ExUnit.Case
  alias ExModbus.Profiles.Fronius

  describe "reading data, function 03" do
    setup do
      {:ok, pid} = ExModbus.Client.start_link(%{ip: {10, 0, 1, 3}})
      {:ok, %{pid: pid, slave_id: 1}}
    end

    test "can read type: string16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: "1.2.3"}} = Fronius.version(pid, slave_id)
    end

    test "can read type: string32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: "SunSpecText"}} = Fronius.manufacturer(pid, slave_id)
    end

    test "can read type: uint16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 1}} = Fronius.device_address(pid, slave_id)
    end

    test "can read type: uint32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 0}} = Fronius.evt1(pid, slave_id)
    end

    test "can read type: float32", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: 1.2122900943140371e-37}} = Fronius.ac(pid, slave_id)
    end

    test "can read type: enum16", %{pid: pid, slave_id: slave_id} do
      assert {:ok, %{data: nil}} = Fronius.st_vnd(pid, slave_id)
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
