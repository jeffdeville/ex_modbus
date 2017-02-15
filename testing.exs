alias ExModbus.Client
alias ExModbus.Profiles.Fronius

{:ok, pid} = Client.start_link(%{ip: {172, 16, 2, 153}})
{:ok, pid} = Client.start_link(%{ip: {10, 0, 1, 3}})
IO.puts inspect ["manufacturer", Fronius.manufacturer(pid, 1)]
IO.puts inspect ["st", Fronius.st(pid, 1)]
IO.puts inspect ["st_vnd", Fronius.st(pid, 1)]
