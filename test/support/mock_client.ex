defmodule MockClient do
  require Logger
  @behaviour ExModbus.ClientBehaviour

  def init(_args) do
    {:ok, {nil, MockClient}}
  end

  def command(<<3, 15, 160, 0, 2>>, _socket, unit_id), do: do_command(123, unit_id)
  def command(<<3, 156, 65, 0, 2>>, _socket, unit_id), do: do_command(123, unit_id)
  def command(_msg, _socket, _unit_id) do
    {:error, :i_am_confused }
  end
  def do_command(data, unit_id) do
    {:ok, %{
        unit_id: unit_id,
        transaction_id: 1,
        data: data
    } }
  end
end
