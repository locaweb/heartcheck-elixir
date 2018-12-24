defmodule TestServer do
  @moduledoc false

  alias Plug.Adapters.Cowboy

  def start do
    {:ok, s} = :ranch_tcp.listen(port: 0)
    {:ok, port} = :inet.port(s)
    :erlang.port_close(s)
    {:ok, socket} = :ranch_tcp.listen(port: port)

    ref = make_ref()

    cowboy_opts = [ref: ref, acceptors: 5, port: port, socket: socket]
    {:ok, cowboy_pid} = Cowboy.http(TestRouter, [], cowboy_opts)
    {:ok, [pid: cowboy_pid, port: port]}
  end
end
