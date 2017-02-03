defmodule ExModbus.ClientBehaviour do
  @callback command(any, any, any) :: {:ok, any} | {:error, any}
  @callback connect(any) :: {:ok, {any, any}} | {:backoff, integer, any}
end
