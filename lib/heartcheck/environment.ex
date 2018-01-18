defmodule HeartCheck.Environment do
  @moduledoc """
  Provides important information about the application's environment, including:

  System info from "uname" Linux command (kernel-name, nodename, kernel-release,
  kernel-version and machine)

  Elixir version

  Phoenix (if available) version

  Fully compatible with Linux (Unix) and Windows systems.
  """

  @unknown_info_word "unknown"

  @doc """
  Returns a map with system information
  """
  @spec info() :: map()
  def info do
    %{
      system_info: get_system_info(),
      elixir_version: System.version(),
      phoenix_version: get_phoenix_version(),
      otp_version: System.otp_release(),
      deps: deps()
    }
  end

  def tuple_to_string_list(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&to_string(&1))
  end

  def string_patterns_matcher(patterns) do
    fn str ->
      Enum.any?(patterns, &(str =~ &1))
    end
  end

  def system_name_matches?(system_abbreviations) do
    :os.type()
    |> tuple_to_string_list()
    |> Enum.any?(string_patterns_matcher(system_abbreviations))
  end

  def system_is_linux?, do: system_name_matches?(["nix", "nux"])

  def system_is_windows?, do: system_name_matches?(["win"])

  def build_prop_string(tuple, joiner) do
    tuple
    |> tuple_to_string_list()
    |> Enum.reduce(fn entry_string, entries_result ->
      entries_result <> joiner <> entry_string
    end)
  end

  def get_sysname, do: build_prop_string(:os.type(), " ")

  def get_release, do: build_prop_string(:os.version(), ".")

  def get_windows_prop(prop_possible_names) do
    Enum.find_value(prop_possible_names, @unknown_info_word, &System.get_env()[&1])
  end

  def get_linux_prop(uname_option) do
    case System.cmd("uname", [uname_option]) do
      {result, 0} ->
        String.trim(result)

      _ ->
        @unknown_info_word
    end
  end

  def system_specific_info_map(@unknown_info_word) do
    %{
      nodename: @unknown_info_word,
      version: @unknown_info_word,
      machine: @unknown_info_word
    }
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
        Map.merge(
          basic_system_info,
          system_specific_info_map(
            get_linux_prop("-n"),
            get_linux_prop("-v"),
            get_linux_prop("-m")
          )
        )

      system_is_windows?() ->
        Map.merge(
          basic_system_info,
          system_specific_info_map(
            get_windows_prop(["COMPUTERNAME", "HOSTNAME"]),
            get_windows_prop(["OS"]),
            get_windows_prop(["PROCESSOR_ARCHITECTURE", "ARCHITECTURE"])
          )
        )

      true ->
        Map.merge(basic_system_info, system_specific_info_map(@unknown_info_word))
    end
  end

  def phoenix_available?, do: function_exported?(Phoenix, :__info__, 1)

  def get_phoenix_version do
    if phoenix_available?() do
      case :application.get_key(:phoenix, :vsn) do
        {:ok, version} -> to_string(version)
        _ -> @unknown_info_word
      end
    else
      "(none)"
    end
  end

  defp deps do
    Application.loaded_applications()
    |> Enum.map(fn {app, _, version} -> {app, to_string(version)} end)
    |> Enum.into(%{})
  end
end
