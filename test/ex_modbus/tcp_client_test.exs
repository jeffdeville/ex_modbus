defmodule TcpClientTest do
  alias ExModbus.TcpClient
  use ExUnit.Case

  describe "init\1" do
    test "when a port is provided, it overrides the default" do
      {:ok, _listen_socket} = :gen_tcp.listen(5003, [:binary, packet: :raw, active: false, reuseaddr: true])
      assert {:ok, {_socket, ExModbus.TcpClient}} = TcpClient.init(%{ip: {127, 0, 0, 1}, port: 5003})
    end

    test "if no connection possible, backoff" do
      assert {:stop, :inverter_inaccessible} = TcpClient.init(%{ip: {127, 0, 0, 1}, port: 5003})
      assert {:stop, :connectder_inaccessible} = TcpClient.init(%{ip: {172, 18, 0, 2}, port: 5002})
    end
  end

  describe "command\3" do
    setup do
      {:ok, pid} = MockTcpSlave.start_link(nil)
      MockTcpSlave.listen(pid)
      {:ok, {socket, _}} =  TcpClient.init(%{ip: {127, 0, 0, 1}, port: 5003})
      {:ok, %{socket: socket}}
    end

    test "when data is retrieved successfully", %{socket: socket} do
      data = <<3, 15, 160, 0, 2>>
      expected_response = %{data: {:read_holding_registers, <<160, 0, 2>>}, unit_id: 1, transaction_id: 1}
      assert {:ok, ^expected_response} = TcpClient.command(data, socket, 1)
    end

    test "when data can not be retrieved", %{socket: socket} do
      assert {:error, _message} = TcpClient.command("bad", socket, 1)
    end
  end
end
