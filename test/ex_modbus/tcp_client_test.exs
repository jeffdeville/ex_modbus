defmodule TcpClientTest do
  alias ExModbus.TcpClient
  use ExUnit.Case

  describe "init\1" do
    test "when just an ip is provided, the port is 502" do
      # Must await use of Connection, because the connection won't fire on
      # init, then. right now it does, and I can't listen on 502 without sudo.
    end

    test "when a port is provided, it overrides the default" do
      {:ok, listen_socket} = :gen_tcp.listen(5002, [:binary, packet: :raw, active: false, reuseaddr: true])
      assert {:ok, {_socket, ExModbus.TcpClient}} = TcpClient.init(%{ip: {127, 0, 0, 1}, port: 5002})
    end

    test "if no connection possible, errors" do
      assert {:error, :econnrefused} = TcpClient.init(%{ip: {127, 0, 0, 1}, port: 5002})
    end
  end

  describe "command\3" do
    setup do
      {:ok, pid} = MockTcpSlave.start_link(nil)
      MockTcpSlave.listen(pid)
      {:ok, {socket, _}} =  TcpClient.init(%{ip: {127, 0, 0, 1}, port: 5002})
      {:ok, %{socket: socket}}
    end

    test "when data is retrieved successfully", %{socket: socket} do
      data = <<3, 15, 160, 0, 2>>
      expected_response = %{unit_id: 1, transaction_id: 1, data: data }
      assert {:ok, expected_response} = TcpClient.command(data, socket, 1)
    end

    test "when data can not be retrieved", %{socket: socket} do
      assert {:error, _message} = TcpClient.command("bad", socket, 1)
    end
  end
end
