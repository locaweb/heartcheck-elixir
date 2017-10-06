defmodule HeartCheck.Environment do
  @moduledoc """
  Provides important information about the application's environment, including:

  System info from "uname" Linux command (kernel-name, nodename, kernel-release, kernel-version and machine)

  Elixir version

  Phoenix (if available) version

  Fully compatible with Linux (Unix) and Windows systems.
  """

  @unknown_info_word "unknown"

  def tupleToStringList(tuple) do
    tuple
    |> Tuple.to_list
    |> Enum.map(fn(entry) -> to_string(entry) end)
  end

  def stringPatternsMatcher(patterns) do
    fn(str) ->
      patterns
      |> Enum.any?(fn(pattern) -> str =~ pattern end)
    end
  end

  def systemNameMatches?(systemAbbreviations) do
    :os.type
    |> tupleToStringList
    |> Enum.any?(stringPatternsMatcher(systemAbbreviations))
  end

  def systemIsLinux? do
    systemNameMatches?(["nix", "nux"])
  end

  def systemIsWindows? do
    systemNameMatches?(["win"])
  end

  def buildPropString(tuple, joiner) do
    tuple
    |> tupleToStringList
    |> Enum.reduce(fn(entryString, entriesResult) -> entriesResult <> joiner <> entryString end)
  end

  def getSysname do
    buildPropString(:os.type, " ")
  end

  def getRelease do
    buildPropString(:os.version, ".")
  end

  def getWindowsProp(propPossibleNames) do
    :os.getenv
    |> Enum.map(fn(entry) -> to_string(entry) end)
    |> Enum.find(@unknown_info_word, stringPatternsMatcher(propPossibleNames))
    |> String.split("=")
    |> Enum.at(1)
  end

  def getLinuxProp(unameOption) do
    unameResult = System.cmd("uname", [unameOption])
    if (elem(unameResult, 1) == 0) do
      unameResult
      |> elem(0)
      |> String.trim
    else
      @unknown_info_word
    end
  end

  def systemSpecificInfoMap(nodename, version, machine) do
    %{
      nodename: nodename,
      version: version,
      machine: machine
    }
  end

  def basicSystemInfoMap do
    %{
      sysname: getSysname(),
      release: getRelease()
    }
  end

  def getSystemInfo do
    basicSystemInfo = basicSystemInfoMap()
    cond do
      systemIsLinux?() ->
        systemSpecificInfoMap(getLinuxProp("-n"), getLinuxProp("-v"), getLinuxProp("-m"))
        |> Map.merge(basicSystemInfo)
      systemIsWindows?() ->
        systemSpecificInfoMap(getWindowsProp(["COMPUTERNAME", "HOSTNAME"]), getWindowsProp(["OS"]), getWindowsProp(["PROCESSOR_ARCHITECTURE", "ARCHITECTURE"]))
        |> Map.merge(basicSystemInfo)
      true ->
        systemSpecificInfoMap(@unknown_info_word, @unknown_info_word, @unknown_info_word)
        |> Map.merge(basicSystemInfo)
    end
  end

  def getVersion(systemAtom) do
    version = systemAtom
    |> :application.get_key(:vsn)
    if (version != :undefined) do
      version
      |> elem(1)
      |> to_string
    else
      @unknown_info_word
    end
  end

  def phoenixAvailable? do
    try do
      Phoenix.__info__(:functions)
      true
    rescue
      UndefinedFunctionError -> false
    end
  end

  def info do
    %{
      system_info: getSystemInfo(),
      elixir_version: getVersion(:elixir),
      phoenix_version: (if (phoenixAvailable?()), do: getVersion(:phoenix), else: "(none)")
    }
  end
end
