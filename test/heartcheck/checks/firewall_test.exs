defmodule HeartCheck.Checks.FirewallTest do
  use ExUnit.Case, async: true

  alias HeartCheck.Checks.Firewall

  setup _tags do
    {:ok, s} = :ranch_tcp.listen(port: 0)
    {:ok, port} = :inet.port(s)
    :erlang.port_close(s)

    {:ok, port: port}
  end

  describe "validate" do
    test "connects to a open port", %{port: port} do
      {:ok, socket} = :ranch_tcp.listen(port: port)
      on_exit fn ->
        :gen_tcp.close(socket)
      end

      assert Firewall.validate("http://localhost:#{port}") == :ok
    end

    test "cannot connect to a closed port", %{port: port} do
      msg = "Failed to connect to host [localhost] on port [#{port}]"

      assert Firewall.validate("http://localhost:#{port}") == {:error, msg}
    end

    test "cannot connect to a closed port with timeout", %{port: port} do
      msg = "Failed to connect to host [localhost] on port [#{port}]"

      assert {:error, ^msg} =
        Firewall.validate("http://localhost:#{port}", timeout: 2000)
    end
  end
end
