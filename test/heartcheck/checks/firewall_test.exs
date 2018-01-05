defmodule HeartCheck.Checks.FirewallTest do
  use ExUnit.Case, async: true

  alias HeartCheck.Checks.Firewall

  describe "validate" do
    test "connects to a open port" do
      {:ok, s} = :ranch_tcp.listen(port: 0)
      {:ok, port} = :inet.port(s)
      :erlang.port_close(s)
      {:ok, socket} = :ranch_tcp.listen(port: port)
      assert Firewall.validate("http://localhost:#{port}") == :ok
      :gen_tcp.close(socket)
    end

    test "cannot connect to a closed port" do
      {:ok, s} = :ranch_tcp.listen(port: 0)
      {:ok, port} = :inet.port(s)
      :erlang.port_close(s)

      msg = "Failed to connect to host [localhost] on port [#{port}]"
      assert Firewall.validate("http://localhost:#{port}") == {:error, msg}
    end

    test "cannot connect to a closed port with timeout" do
      {:ok, s} = :ranch_tcp.listen(port: 0)
      {:ok, port} = :inet.port(s)
      :erlang.port_close(s)

      msg = "Failed to connect to host [localhost] on port [#{port}]"
      assert Firewall.validate("http://localhost:#{port}", timeout: 2000) == {:error, msg}
    end
  end
end
