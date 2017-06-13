defmodule MockTcpSlave do
  use GenServer
  require Logger

  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(_args) do
    :gen_tcp.listen(5003, [:binary, packet: :raw, active: false, reuseaddr: true])
  end

  def listen(pid) do
    GenServer.cast(pid, :listen)
  end

  def handle_cast(:listen, socket) do
    # Note: This is a blocking listener - so it can still only receive 1 message at a time
    {:ok, client} = :gen_tcp.accept(socket)
    case :gen_tcp.recv(client, 0) do
      {:ok, data} -> :gen_tcp.send(client, data)
    end
    {:noreply, socket}
  end
end
