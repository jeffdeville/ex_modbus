defmodule ExModbus.RtuClient do
  @moduledoc """
  ModbusRTU client to manage communication with a device
  """

  use GenServer
  require Logger

  @read_timeout 5000

  # Public Interface

  def start_link(args = %{tty: _tty, speed: _speed}) do
    GenServer.start_link(__MODULE__, args)
  end

  def read_data(pid, slave_id, start_address, count) do
    GenServer.call(pid, {:read_holding_registers, %{slave_id: slave_id, start_address: start_address, count: count}})
  end

  def read_coils(pid, slave_id, start_address, count) do
    GenServer.call(pid, {:read_coils, %{slave_id: slave_id, start_address: start_address, count: count}})
  end

  @doc """
  Write a single coil at address. Possible states are `:on` and `:off`.
  """
  def write_single_coil(pid, slave_id, address, state) do
    GenServer.call(pid, {:write_single_coil, %{slave_id: slave_id, start_address: address, state: state}})
  end

  def generic_call(pid, slave_id, {call, address, count, transform}) do
    %{data: {_type, data}} = GenServer.call(pid, {call, %{slave_id: slave_id, start_address: address, count: count}})
    transform.(data)
  end


  # GenServer Callbacks

  def init(%{tty: tty, speed: speed}) do
     {:ok, uart_pid} = Nerves.UART.start_link
     Nerves.UART.open(uart_pid, tty, speed: speed, active: false)
     Nerves.UART.configure(uart_pid, framing: {Nerves.UART.Framing.Modbus, slave_id: 1})
     {:ok, uart_pid}
  end

  def handle_call({:read_coils, %{slave_id: slave_id, start_address: address, count: count}}, _from, serial) do
    # limits the number of coils returned to the number `count` from the request
    limit_to_count = fn msg ->
                        {:read_coils, lst} = msg.data
                        {_, elems} = Enum.split(lst, -count)
                        %{msg | data: {:read_coils, elems}}
    end
    response = Modbus.Packet.read_coils(address, count)
               |> Modbus.Rtu.wrap_packet(slave_id)
               |> send_and_rcv_packet(serial)
               |> limit_to_count.()

    {:reply, response, serial}
  end

  def handle_call({:read_holding_registers, %{slave_id: slave_id, start_address: address, count: count}}, _from, serial) do
    response = Modbus.Packet.read_holding_registers(address, count)
               |> Modbus.Rtu.wrap_packet(slave_id)
               |> send_and_rcv_packet(serial)
    {:reply, response, serial}
  end

  def handle_call({:write_single_coil, %{slave_id: slave_id, start_address: address, state: state}}, _from, serial) do
    response = Modbus.Packet.write_single_coil(address, state)
               |> Modbus.Rtu.wrap_packet(slave_id)
               |> send_and_rcv_packet(serial)
    {:reply, response, serial}
  end

  def handle_call(msg, _from, state) do
    Logger.info "Unknown handle_cast msg: #{inspect msg}"
    {:reply, "unknown call message", state}
  end

  def handle_info({:nerves_uart, _tty, data}, state) do
    Logger.debug "Got back #{inspect data}"
    {:noreply, state}
  end

  defp send_and_rcv_packet(msg, serial) do
    Logger.debug "Sending: #{inspect msg}"

    Nerves.UART.flush(serial)
    Nerves.UART.write(serial, msg)

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

end