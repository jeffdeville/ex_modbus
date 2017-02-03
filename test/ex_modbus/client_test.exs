defmodule MockClient do
  require Logger
  @behaviour ExModbus.ClientBehaviour
  def connect(_args) do
    {:ok, {nil, MockClient}}
  end

  def command(<<3, 15, 160, 0, 2>>, socket, unit_id) do
    {:ok, %{
        unit_id: unit_id,
        transaction_id: 1,
        data: 123
    } }
  end

  def command(msg, socket, unit_id) do
    IO.puts inspect "---------------------------"
    IO.puts inspect "Unrecognized message"
    IO.puts inspect msg
    IO.puts inspect "---------------------------"

    {:error, :i_am_confused }
  end
end

defmodule ClientTest do
  alias ExModbus.Client
  use ExUnit.Case

  describe "start_link\2" do
    test "when passing in args with strategy" do
      {:ok, pid} = Client.start_link(%{strategy: MockClient})
      assert Client.get_strategy(pid) == {:ok, "MockClient"}
    end
    # Can't test this, until I have a TCP server to connect to
    test "when passing in an ip address, uses TcpClient" do
      {:ok, slave_pid} = MockTcpSlave.start_link(nil)
      MockTcpSlave.listen(slave_pid)

      {:ok, pid} = Client.start_link(%{ip: {127, 0, 0, 1}, port: 5002})
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
  test "read_data\4" do
    {:ok, pid} = Client.start_link(%{strategy: MockClient})

    Client.read_data(pid, 1, 40001, 2) == {:ok, %{
        unit_id:        1,
        transaction_id: 1,
        data:           123
      } }
  end
end
