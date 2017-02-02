defmodule ExModbus.TcpClient do
  @moduledoc """
  ModbusTCP client to manage communication with a device
  """

  require Logger

  @read_timeout 4000

  def init(%{ip: ip, port: port}) do
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, {:active, false}])
    {:ok, {socket, ExModbus.TcpClient}}
  end

  def send_and_rcv_packet(msg, socket, unit_id) do
    #Logger.debug "Packet: #{inspect msg}"
    :ok = :gen_tcp.send(socket, wrapped_msg)
    {:ok, packet} = :gen_tcp.recv(socket, 0, @read_timeout)
    # XXX - handle {:error, closed} and try to reconnect
    #Logger.debug "Response: #{inspect packet}"
    unwrapped = Modbus.Tcp.unwrap_packet(packet)
    {:ok, data} = Modbus.Packet.parse_response_packet(unwrapped.packet)
    %{unit_id: unwrapped.unit_id, transaction_id: unwrapped.transaction_id, data: data}
  end

  defdelegate wrap_packet(packet, unit_id, transaction_id), to: Modbus.Tcp
  defdelegate wrap_packet(packet, unit_id), to: Modbus.Tcp
end
