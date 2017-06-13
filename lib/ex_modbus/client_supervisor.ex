defmodule ExModbus.ClientSupervisor do
  @moduledoc """
  This ClientSupervisor allows you to spin up multiple connections.
  I don't really know why you'd really care about that though. If they're
  doing a simple_one_for_one, what is the difference between this, and just
  spinning them all up manually? Same call, really.
  """
  use Supervisor

  def start_client(args) do
    Supervisor.start_child(:client_supervisor, [args])
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :client_supervisor)
  end

  def init([]) do
    children = [
      worker(ExModbus.Client, [], restart: :temporary) # if it crashes, I wouldn't know to call it again anyway
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
