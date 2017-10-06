defmodule HeartCheck.EnvironmentTest do
  use ExUnit.Case

  import Mock

  alias HeartCheck.Environment

  @moduletag capture_log: true

  test "it converts a tuple to a string list" do
    assert Environment.tupleToStringList({'abc', 'def'}) == ["abc", "def"]
    assert Environment.tupleToStringList({:ghi, :jkl, :mno}) == ["ghi", "jkl", "mno"]
  end

  test "it creates a string patterns matcher" do
    assert Environment.stringPatternsMatcher(["ab", "cd"]).("abba")
    assert Environment.stringPatternsMatcher(["ab", "cd"]).("ecde")
    refute Environment.stringPatternsMatcher(["ab", "cd"]).("acbd")
  end

  test "it correctly builds prop String from separated values" do
    assert Environment.buildPropString({:unix, :linux}, " ") == "unix linux"
    assert Environment.buildPropString({4, 0, 0}, ".") == "4.0.0"
  end

  test "it correctly matches system name with patterns given" do
    with_mock System, [
      cmd: fn("uname", args) ->
        cond do
          Enum.at(args, 0) == "-n" ->
            {"ADM0000", 0}
          Enum.at(args, 0) == "-v" ->
            {"Ubuntu 16.06", 0}
          Enum.at(args, 0) == "-m" ->
            {"x86", 0}
        end
      end
    ] do
      assert Environment.getLinuxProp("-n") == "ADM0000"
      assert Environment.getLinuxProp("-v") == "Ubuntu 16.06"
      assert Environment.getLinuxProp("-m") == "x86"
    end
  end

  test "it correctly builds a map with system specific values" do
    assert Environment.systemSpecificInfoMap("ADM0000", "Ubuntu 16.06", "x86") == %{
      nodename: "ADM0000",
      version: "Ubuntu 16.06",
      machine: "x86"
    }
  end

  test "it correctly gets Elixir and Phoenix versions" do
    :code.unstick_mod(:application)
    with_mock :application, [
      get_key: fn(system, :vsn) ->
        cond do
          system == :elixir ->
            {:ok, '1.4.0'}
          system == :phoenix ->
            {:ok, '1.0.0'}
        end
      end
    ] do
      assert Environment.getVersion(:elixir) == "1.4.0"
      assert Environment.getVersion(:phoenix) == "1.0.0"
    end
  end

  test "it correctly checks if Phoenix is available" do
    refute Environment.phoenixAvailable?()
    Code.eval_string """
      defmodule Phoenix do
      end
    """
    assert Environment.phoenixAvailable?()
  end
end
