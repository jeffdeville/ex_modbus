defmodule ExModbus.Client do
  # use GenServer
  require Logger
  # Public Interface

  def start_link(args, opts \\ [])
  def start_link({_a, _b, _c, _d} = ip, opts), do: start_link(ip, Modbus.Tcp.port, opts)
  def start_link({_a, _b, _c, _d} = ip, port, opts) do
    args = %{ip: ip, port: port, strategy: ExModbus.TcpClient}
    GenServer.start_link(__MODULE__, args, opts)
  end
  def start_link(%{tty: _tty, speed: _speed} = args, opts) do
    args = %{ args | strategy: ExModbus.RtuClient}
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(%{strategy: strategy} = args) do
    apply(strategy, :init, [args])
  end

  def read_data(pid, unit_id, start_address, count) do
    GenServer.call(pid, {:read_holding_registers, %{unit_id: unit_id, start_address: start_address, count: count}})
  end

  def read_coils(pid, unit_id, start_address, count) do
    GenServer.call(pid, {:read_coils, %{unit_id: unit_id, start_address: start_address, count: count}})
  end

  @doc """
  Write a single coil at address. Possible states are `:on` and `:off`.
  """
  def write_single_coil(pid, unit_id, address, state) do
    GenServer.call(pid, {:write_single_coil, %{unit_id: unit_id, start_address: address, state: state}})
  end


  def write_single_register(pid, unit_id, address, data) do
    GenServer.call(pid, {:write_single_register, %{unit_id: unit_id, start_address: address, data: data}})
  end


  def write_multiple_registers(pid, unit_id, address, data) do
    GenServer.call(pid, {:write_multiple_registers, %{unit_id: unit_id, start_address: address, data: data}})
  end


  def generic_call(pid, unit_id, {call, address, count, transform}) do
    %{data: {_type, data}} = GenServer.call(pid, {call, %{unit_id: unit_id, start_address: address, count: count}})
    transform.(data)
  end

  def handle_call({:read_coils, %{unit_id: unit_id, start_address: address, count: count}}, _from, {transport, strategy}) do
    # limits the number of coils returned to the number `count` from the request
    limit_to_count = fn msg ->
                        {:read_coils, lst} = msg.data
                        {_, elems} = Enum.split(lst, -count)
                        %{msg | data: {:read_coils, elems}}
    end
    response = Modbus.Packet.read_coils(address, count)
               |> strategy.wrap_packet(unit_id)
               |> strategy.send_and_rcv_packet(transport, unit_id)
               |> limit_to_count.()

    {:reply, response, {transport, strategy}}
  end

  def handle_call({:read_holding_registers, %{unit_id: unit_id, start_address: address, count: count}}, _from, {transport, strategy}) do
    response = Modbus.Packet.read_holding_registers(address, count)
               |> strategy.wrap_packet(unit_id)
               |> strategy.send_and_rcv_packet(transport, unit_id)
    {:reply, response, {transport, strategy}}
  end

  def handle_call({:write_single_coil, %{unit_id: unit_id, start_address: address, state: state}}, _from, {transport, strategy}) do
    response = Modbus.Packet.write_single_coil(address, state)
               |> strategy.wrap_packet(unit_id)
               |> strategy.send_and_rcv_packet(transport, unit_id)
    {:reply, response, {transport, strategy}}
  end

  def handle_call({:write_single_register, %{unit_id: unit_id, start_address: address, data: data}}, _from, {transport, strategy}) do
    response = Modbus.Packet.write_single_register(address,data)
               |> strategy.wrap_packet(unit_id)
               |> strategy.send_and_rcv_packet(transport, unit_id)
    {:reply, response, {transport, strategy}}
  end

  def handle_call({:write_multiple_registers, %{unit_id: unit_id, start_address: address, data: data}}, _from, {transport, strategy}) do
    response = Modbus.Packet.write_multiple_registers(address, data)
               |> strategy.wrap_packet(unit_id)
               |> strategy.send_and_rcv_packet(transport, unit_id)
    {:reply, response, {transport, strategy}}
  end

  def handle_call(msg, _from, state) do
    Logger.info "Unknown handle_cast msg: #{inspect msg}"
    {:reply, "unknown call message", state}
  end
end
