defmodule ExModbus.RtuClient do
  @moduledoc """
  ModbusRTU client to manage communication with a device
  """
  require Logger

  @read_timeout 5000

  # GenServer Callbacks

  def init(%{tty: tty, speed: speed}) do
     {:ok, uart_pid} = Nerves.UART.start_link
     Nerves.UART.open(uart_pid, tty, speed: speed, active: false)
     Nerves.UART.configure(uart_pid, framing: {ExModbus.Nerves.UART.Framing.Modbus, slave_id: 1})
     {:ok, {uart_pid, ExModbus.RtuClient}}
  end

  def send_and_rcv_packet(msg, serial, unit_id) do
    Logger.debug "Sending: #{inspect wrapped_msg}"

    Nerves.UART.flush(serial)
    Nerves.UART.write(serial, wrapped_msg)

    case Nerves.UART.read(serial, @read_timeout) do
      # 1 here is slave_id, should be a variable
      {:ok, <<1::size(8), _rest_of_packet::binary>> = packet} ->
        unwrapped = Modbus.Rtu.unwrap_packet(packet)
        {:ok, data} = Modbus.Packet.parse_response_packet(unwrapped.packet)
        %{slave_id: unwrapped.slave_id, data: data}
      {:ok, <<packet::binary>> = packet} ->
        {:error, "invalid packet doesn't match slave ID"}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defdelegate wrap_packet(packet, unit_id), to: Modbus.Rtu
end
