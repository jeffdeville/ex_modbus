defmodule ClientTest do
  alias ExModbus.Client
  use ExUnit.Case

  setup do
    {:ok, mock_client_pid} = Client.start_link(%{strategy: MockClient})
    {:ok, mock_tcp_slave_pid} = MockTcpSlave.start_link(nil)
    MockTcpSlave.listen(mock_tcp_slave_pid)

    {:ok, %{mock_client: mock_client_pid}}
  end

  describe "start_link\2" do
    test "when passing in args with strategy", %{mock_client: pid} do
      assert Client.get_strategy(pid) == {:ok, "MockClient"}
    end

    test "when passing in an ip address, uses TcpClient" do
      {:ok, pid} = Client.start_link(%{ip: {127, 0, 0, 1}, port: 5003})
      assert Client.get_strategy(pid) == {:ok, "ExModbus.TcpClient"}
    end
    # Can't test this, unless I can find a way to simulate a Rtu conn
    # test "when passing in tty and speed, uses RtuClient" do
    # end
  end

  test "connect\1 calls the provided strategy" do
    assert Client.connect(nil, %{strategy: MockClient}) == {:ok, {nil, MockClient}}
  end

  # TODO: read_data is the only call I've used so far, so it's the only
  # one I really know how to test for now.
  test "read_data\4", %{mock_client: pid} do
    assert {:ok, %{
            unit_id:        1,
            transaction_id: 1,
            data:           123
    } } = Client.read_data(pid, 1, 40001, 2)
  end
end
