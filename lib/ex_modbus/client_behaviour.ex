defmodule ExModbus.ClientBehaviour do
  @callback command(any, any, any) :: {:ok, any} | {:error, any}
  @callback init(any) :: {:ok, {any, any}}
end
