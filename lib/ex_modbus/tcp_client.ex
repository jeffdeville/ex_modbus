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

  def connect(%{ip: {_, _, _, _} = ip, port: port}), do: do_connect(%{host_or_ip: ip, port: port})
  def connect(%{host: host, port: port}), do: do_connect(%{host_or_ip: String.to_charlist(host), port: port})
  def connect(%{host_or_ip: _host_or_ip, port: _port}=args), do: do_connect(args)
  def do_connect(%{host_or_ip: host_or_ip, port: port}) do
    case :gen_tcp.connect(host_or_ip, port, [:binary, {:active, false}]) do
      {:ok, socket} -> {:ok, {socket, ExModbus.TcpClient}}
      {:error, _} -> {:backoff, 1000, %{host_or_ip: host_or_ip, port: port}}
    end
  end

  def disconnect(info, {socket, _}) do
    :ok = :gen_tcp.close(socket)
    case info do
      {:close, from} -> Connection.reply(from, :ok)
      {:error, :closed} -> Logger.error("Connection closed")
      {:error, reason} -> Logger.error("Connection Error: #{inspect reason}")
    end
    {:connect, :reconnect, {nil, ExModbus.TcpClient}}
  end

  # This code doesn't belong in the genserver, because it could crash, which
  # crashes the entire tcp connection.  I'd rather have this client
  def command(msg, socket, unit_id) do
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
  end
end

