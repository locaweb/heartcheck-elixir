defmodule HeartCheck.Environment do
  @moduledoc """
  Provides important information about the application's environment, including:

  System info from "uname" Linux command (kernel-name, nodename, kernel-release, kernel-version and machine)

  Elixir version

  Phoenix (if available) version

  Fully compatible with Linux (Unix) and Windows systems.
  """

  @unknown_info_word "unknown"

  def tuple_to_string_list(tuple) do
    tuple
    |> Tuple.to_list
    |> Enum.map(fn(entry) -> to_string(entry) end)
  end

  def string_patterns_matcher(patterns) do
    fn(str) ->
      patterns
      |> Enum.any?(fn(pattern) -> str =~ pattern end)
    end
  end

  def system_name_matches?(system_abbreviations) do
    :os.type
    |> tuple_to_string_list
    |> Enum.any?(string_patterns_matcher(system_abbreviations))
  end

  def system_is_linux? do
    system_name_matches?(["nix", "nux"])
  end

  def system_is_windows? do
    system_name_matches?(["win"])
  end

  def build_prop_string(tuple, joiner) do
    tuple
    |> tuple_to_string_list
    |> Enum.reduce(fn(entry_string, entries_result) -> entries_result <> joiner <> entry_string end)
  end

  def get_sysname do
    build_prop_string(:os.type, " ")
  end

  def get_release do
    build_prop_string(:os.version, ".")
  end

  def get_windows_prop(prop_possible_names) do
    :os.getenv
    |> Enum.map(fn(entry) -> to_string(entry) end)
    |> Enum.find(@unknown_info_word, string_patterns_matcher(prop_possible_names))
    |> String.split("=")
    |> Enum.at(1)
  end

  def get_linux_prop(uname_option) do
    uname_result = System.cmd("uname", [uname_option])
    if elem(uname_result, 1) == 0 do
      uname_result
      |> elem(0)
      |> String.trim
    else
      @unknown_info_word
    end
  end

  def system_specific_info_map(nodename, version, machine) do
    %{
      nodename: nodename,
      version: version,
      machine: machine
    }
  end

  def basic_system_info_map do
    %{
      sysname: get_sysname(),
      release: get_release()
    }
  end

  def get_system_info do
    basic_system_info = basic_system_info_map()
    cond do
      system_is_linux?() ->
        basic_system_info
        |> Map.merge(system_specific_info_map(get_linux_prop("-n"), get_linux_prop("-v"), get_linux_prop("-m")))
      system_is_windows?() ->
        basic_system_info
        |> Map.merge(system_specific_info_map(
          get_windows_prop(["COMPUTERNAME", "HOSTNAME"]),
          get_windows_prop(["OS"]),
          get_windows_prop(["PROCESSOR_ARCHITECTURE", "ARCHITECTURE"])
        ))
      true ->
        basic_system_info
        |> Map.merge(system_specific_info_map(@unknown_info_word, @unknown_info_word, @unknown_info_word))
    end
  end

  def get_version(system_atom) do
    case :application.get_key(system_atom, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> @unknown_info_word
    end
  end

  def phoenix_available? do
    function_exported?(Phoenix, :__info__, 1)
  end

  def info do
    %{
      system_info: get_system_info(),
      elixir_version: get_version(:elixir),
      phoenix_version: (if phoenix_available?(), do: get_version(:phoenix), else: "(none)")
    }
  end
end
