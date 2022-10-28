defmodule HeartCheck.EnvironmentTest do
  use ExUnit.Case

  import Mock

  alias HeartCheck.Environment

  @moduletag capture_log: true

  test "it lists dependencies" do
    assert :deps in Map.keys(Environment.info())
    assert :ex_unit in Map.keys(Environment.info()[:deps])
  end

  test "it informs the Erlang/OTP version" do
    assert :otp_version in Map.keys(Environment.info())
    assert Environment.info()[:otp_version] != nil
  end

  test "it converts a tuple to a string list" do
    assert Environment.tuple_to_string_list({'abc', 'def'}) == ["abc", "def"]
    assert Environment.tuple_to_string_list({:ghi, :jkl, :mno}) == ["ghi", "jkl", "mno"]
  end

  test "it creates a string patterns matcher" do
    assert Environment.string_patterns_matcher(["ab", "cd"]).("abba")
    assert Environment.string_patterns_matcher(["ab", "cd"]).("ecde")
    refute Environment.string_patterns_matcher(["ab", "cd"]).("acbd")
  end

  test "it correctly builds prop String from separated values" do
    assert Environment.build_prop_string({:unix, :linux}, " ") == "unix linux"
    assert Environment.build_prop_string({4, 0, 0}, ".") == "4.0.0"
  end

  test "it correctly matches system name with patterns given" do
    with_mock System,
      cmd: fn "uname", args ->
        case Enum.at(args, 0) do
          "-n" ->
            {"ADM0000", 0}

          "-v" ->
            {"Ubuntu 16.06", 0}

          "-m" ->
            {"x86", 0}
        end
      end do
      assert Environment.get_linux_prop("-n") == "ADM0000"
      assert Environment.get_linux_prop("-v") == "Ubuntu 16.06"
      assert Environment.get_linux_prop("-m") == "x86"
    end

    with_mock System,
      get_env: fn ->
        %{
          "COMPUTERNAME" => "MyComputer",
          "HOSTNAME" => "user-pc",
          "OS" => "Windows_NT",
          "PROCESSOR_ARCHITECTURE" => "AMD64",
          "ARCHITECTURE" => "AMD64"
        }
      end do
      assert Environment.get_windows_prop(["COMPUTERNAME", "HOSTNAME"]) == "MyComputer"
      assert Environment.get_windows_prop(["HOSTNAME", "COMPUTERNAME"]) == "user-pc"
      assert Environment.get_windows_prop(["OS"]) == "Windows_NT"
      assert Environment.get_windows_prop(["PROCESSOR_ARCHITECTURE", "ARCHITECTURE"]) == "AMD64"
    end
  end

  test "it return default unknown when it is not available" do
    with_mock System,
      cmd: fn "uname", args ->
        case Enum.at(args, 0) do
          "-n" -> nil
          "-v" -> nil
          "-m" -> nil
        end
      end do
      assert Environment.get_linux_prop("-n") == "unknown"
      assert Environment.get_linux_prop("-v") == "unknown"
      assert Environment.get_linux_prop("-m") == "unknown"
    end

    with_mock System,
      get_env: fn -> nil end do
      assert Environment.get_windows_prop(["COMPUTERNAME", "HOSTNAME"]) == "unknown"
      assert Environment.get_windows_prop(["OS"]) == "unknown"
      assert Environment.get_windows_prop(["PROCESSOR_ARCHITECTURE", "ARCHITECTURE"]) == "unknown"
    end
  end

  test "it correctly builds a map with system specific values" do
    expected = %{
      nodename: "ADM0000",
      version: "Ubuntu 16.06",
      machine: "x86"
    }

    assert ^expected = Environment.system_specific_info_map("ADM0000", "Ubuntu 16.06", "x86")
  end

  test "it correctly gets Elixir version" do
    with_mock System,
      version: fn ->
        "1.4.0"
      end do
      assert System.version() == "1.4.0"
    end
  end

  test "it correctly gets Phoenix version" do
    :code.unstick_mod(:application)

    with_mock :application,
      get_key: fn :phoenix, :vsn ->
        {:ok, '1.0.0'}
      end do
      refute Environment.phoenix_available?()

      Code.eval_string("""
        defmodule Phoenix do
        end
      """)

      assert Environment.phoenix_available?()
      assert Environment.get_phoenix_version() == "1.0.0"
    end
  end
end
