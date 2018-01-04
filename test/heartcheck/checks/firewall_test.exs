defmodule HeartCheck.Checks.FirewallTest do
  use ExUnit.Case, async: true

  alias HeartCheck.Checks.Firewall

  describe "validate" do
    test "connects to a open port" do
      port = 30001
      {:ok, socket} = :gen_tcp.listen(port, [])
      assert Firewall.validate("http://localhost:#{port}") == :ok
      :gen_tcp.close(socket)
    end

    test "cannot connect to a closed port" do
      msg = "Failed to connect to host [localhost] on port [35530]"
      assert Firewall.validate("http://localhost:35530") == {:error, msg}
    end

    test "cannot connect to a closed port with timeout" do
      msg = "Failed to connect to host [localhost] on port [35540]"
      assert Firewall.validate("http://localhost:35540", timeout: 2000) == {:error, msg}
    end

    test "try to use a list of urls to validate if all ports are opened" do
      port1 = 30002
      port2 = 30003
      {:ok, socket1} = :gen_tcp.listen(port1, [])
      {:ok, socket2} = :gen_tcp.listen(port2, [])

      url_list = [
        "http://localhost:#{port1}",
        "http://localhost:#{port2}"
      ]

      assert Firewall.validate(url_list) == :ok

      :gen_tcp.close(socket1)
      :gen_tcp.close(socket2)
    end

    test "try to use a list of urls to validate if all ports are closed" do
      url_list = [
        "http://localhost:30000",
        "http://localhost2:31000"
      ]

      msg1 = "Failed to connect to host [localhost] on port [30000]"
      msg2 = "Failed to connect to host [localhost2] on port [31000]"

      assert Firewall.validate(url_list) == {:error, [msg1, msg2]}
    end
  end
end
