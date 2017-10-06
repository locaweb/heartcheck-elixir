defmodule HeartCheck.EnvironmentTest do
  use ExUnit.Case

  import Mock

  alias HeartCheck.Environment

  @moduletag capture_log: true

  test "it converts a tuple to a string list" do
    assert Environment.tuple_to_string_list({'abc', 'def'}) == ["abc", "def"]
    assert Environment.tuple_to_string_list({:ghi, :jkl, :mno}) ==
      ["ghi", "jkl", "mno"]
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
      assert Environment.get_linux_prop("-n") == "ADM0000"
      assert Environment.get_linux_prop("-v") == "Ubuntu 16.06"
      assert Environment.get_linux_prop("-m") == "x86"
    end
  end

  test "it correctly builds a map with system specific values" do
    expected = %{
      nodename: "ADM0000",
      version: "Ubuntu 16.06",
      machine: "x86"
    }

    assert ^expected = Environment.system_specific_info_map(
      "ADM0000", "Ubuntu 16.06","x86")
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
      assert Environment.get_version(:elixir) == "1.4.0"
      assert Environment.get_version(:phoenix) == "1.0.0"
    end
  end

  test "it correctly checks if Phoenix is available" do
    refute Environment.phoenix_available?()

    Code.eval_string """
      defmodule Phoenix do
      end
    """

    assert Environment.phoenix_available?()
  end
end
