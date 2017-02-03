defmodule ExModbus.Client do
  use GenServer
  require Logger

  def start_link(args, opts \\ [])
  # testing
  def start_link(%{strategy: strategy} = args, opts), do: GenServer.start_link(ExModbus.Client, args, opts)
  # TCP
  def start_link(%{ip: ip, port: port}, opts), do: start_link(%{ip: ip, port: port, strategy: ExModbus.TcpClient}, opts)
  def start_link(%{ip: ip}, opts), do: start_link(%{ip: ip, port: Modbus.Tcp.port, strategy: ExModbus.TcpClient}, opts)
  # RTU
  def start_link(%{tty: _tty, speed: _speed} = args, opts) do
    args = Map.merge(args, %{strategy: ExModbus.RtuClient})
    GenServer.start_link(ExModbus.Client, args, opts)
  end

  def init(%{strategy: strategy} = args) do
    apply(strategy, :init, [args])
  end

  def read_data(pid, unit_id, start_address, count) do
    GenServer.call(pid, {:read_holding_registers, %{unit_id: unit_id, start_address: start_address, data: count}})
  end

  def read_coils(pid, unit_id, start_address, count) do
    GenServer.call(pid, {:read_coils, %{unit_id: unit_id, start_address: start_address, data: count}})
  end

  @doc """
  Write a single coil at address. Possible states are `:on` and `:off`.
  """
  def write_single_coil(pid, unit_id, address, state) do
    GenServer.call(pid, {:write_single_coil, %{unit_id: unit_id, start_address: address, data: state}})
  end

  def write_single_register(pid, unit_id, address, data) do
    GenServer.call(pid, {:write_single_register, %{unit_id: unit_id, start_address: address, data: data}})
  end

  def write_multiple_registers(pid, unit_id, address, data) do
    GenServer.call(pid, {:write_multiple_registers, %{unit_id: unit_id, start_address: address, data: data}})
  end

  def get_strategy(pid) do
    GenServer.call(pid, :get_strategy)
  end

  def handle_call({:read_coils, %{unit_id: unit_id, start_address: address, count: count}}, _from, {transport, strategy}) do
    # limits the number of coils returned to the number `count` from the request
    limit_to_count = fn msg ->
                        {:read_coils, lst} = msg.data
                        {_, elems} = Enum.split(lst, -count)
                        %{msg | data: {:read_coils, elems}}
    end
    response = message_slave(:read_coils, address, count, unit_id, transport, strategy)
    |> limit_to_count.()
    {:reply, response, {transport, strategy}}
  end

  def handle_call({action, %{unit_id: unit_id, start_address: address, data: data}}, _from, {transport, strategy}) do
    response = message_slave(action, address, data, unit_id, transport, strategy)
    {:reply, response, {transport, strategy}}
  end

  def handle_call(:get_strategy, _from, {_, strategy} = state) do
    {:reply, {:ok, inspect(strategy)}, state}
  end

  def handle_info(msg, _from, state) do
    Logger.info "Unknown handle_cast msg: #{inspect msg}"
    {:noreply, state}
  end

  defp message_slave(action, address, data, unit_id, transport, strategy) do
    apply(Modbus.Packet, action, [address, data])
    |> strategy.command(transport, unit_id)
  end
end
