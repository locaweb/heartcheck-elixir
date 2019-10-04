defmodule TestServer do
  @moduledoc false

  alias Plug.Adapters.Cowboy

  def start do
    ref = make_ref()
    cowboy_opts = [port: 0, ref: ref, transport_options: [num_acceptors: 5]]
    {:ok, cowboy_pid} = Cowboy.http(TestRouter, [], cowboy_opts)
    Process.link(cowboy_pid)
    port = :ranch.get_port(ref)

    {:ok, [pid: cowboy_pid, port: port]}
  end
end
