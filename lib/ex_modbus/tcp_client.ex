defmodule ExModbus.TcpClient do
  @moduledoc """
  ModbusTCP client to manage communication with a device
  """
  @behaviour ExModbus.ClientBehaviour

  require Logger

  @read_timeout 4000

  defdelegate wrap_packet(packet, unit_id, transaction_id), to: Modbus.Tcp
  defdelegate wrap_packet(packet, unit_id), to: Modbus.Tcp
  defdelegate unwrap_packet(packet), to: Modbus.Tcp

  def init(%{ip: ip, port: port}) do
    case :gen_tcp.connect(ip, port, [:binary, {:active, false}]) do
      {:ok, socket} -> {:ok, {socket, ExModbus.TcpClient}}
      {:error, :econnrefused} -> {:error, :econnrefused}
    end
  end

  def command(msg, socket, unit_id) do
    # NOTE - I can't use 'with' on elixir versions below 1.3, so I
    # need to rewrite this
    with wrapped_packet = wrap_packet(msg, unit_id),
         {:ok, resp_packet} <- send_receive(wrapped_packet, socket),
         Logger.debug("Response: #{inspect resp_packet}"),
         unwrapped_resp_packet = unwrap_packet(resp_packet),
         Logger.debug("Unwrapped: #{inspect unwrapped_resp_packet}"),
         {:ok, data} <- Modbus.Packet.parse_response_packet(unwrapped_resp_packet.packet),
         Logger.debug("Parsed: #{inspect data}")
    do
      {:ok, %{
          unit_id: unit_id,
          transaction_id: unwrapped_resp_packet.transaction_id,
          data: data
      } }
    end
  end

  def send_receive(msg, socket) do
    Logger.debug "Packet: #{inspect msg}"
    :ok = :gen_tcp.send(socket, msg)
    # Need to change this to be non-blocking, or will this be a problem since
    # we're not going to be hitting the same device repeatedly? What happens
    # to a device that gets flooded with packets?
    :gen_tcp.recv(socket, 0, @read_timeout)
    # {:ok, packet} = :gen_tcp.recv(socket, 0, @read_timeout)
    # XXX - handle {:error, closed} and try to reconnect
    # Logger.debug "Response: #{inspect packet}"

    # Should not be doing this work here either. Let the client call back out to the strategy
    # unwrapped = Modbus.Tcp.unwrap_packet(packet)
    # {:ok, data} = Modbus.Packet.parse_response_packet(unwrapped.packet)
    # %{unit_id: unwrapped.unit_id, transaction_id: unwrapped.transaction_id, data: data}
  end
end

