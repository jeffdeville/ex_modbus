defmodule MockClient do
  require Logger
  @behaviour ExModbus.ClientBehaviour

  def connect(_args) do
    {:ok, {nil, MockClient}}
  end

  def command(<<3, 15, 160, 0, 2>>, _socket, unit_id) do
    {:ok, %{
        unit_id: unit_id,
        transaction_id: 1,
        data: 123
    } }
  end

  def command(<<3, 156, 65, 0, 2>>, _socket, unit_id) do
    {:ok, %{
        unit_id: unit_id,
        transaction_id: 1,
        data: 123
    } }
  end

  def command(_msg, _socket, _unit_id) do
    {:error, :i_am_confused }
  end
end
