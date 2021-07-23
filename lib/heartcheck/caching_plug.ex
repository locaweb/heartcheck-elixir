defmodule HeartCheck.CachingPlug do
  @moduledoc """
  A plug that uses cached results of heartchecks.

  The refresh time for the checks is 300000 milliseconds (5 minutes) and it
  can be set using the `:ttl` key in the plug options.

  The other options are the same as `HeartCheck.Plug`.
  """

  require Logger

  alias Plug.Conn

  alias HeartCheck.CachingPlug.Server
  alias HeartCheck.Plug

  @type find_server :: {:ok, GenServer.server()} | {:error, term} | :error

  @default_ttl 300_000

  def init(options), do: Plug.init(options)

  def call(conn = %Conn{path_info: ["functional"]}, options = %{functional: heartcheck}) do
    response(conn, find_server(heartcheck, options))
  end

  def call(conn = %Conn{path_info: []}, options = %{heartcheck: heartcheck}) do
    response(conn, find_server(heartcheck, options))
  end

  def call(conn, options), do: Plug.call(conn, options)

  @spec find_server(atom, map()) :: find_server
  defp find_server(heartcheck, options) do
    ttl = Map.get(options, :ttl, @default_ttl)
    result = Server.start_link(heartcheck, ttl)

    case result do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
      {:error, reason} -> {:error, reason}
      _ -> :error
    end
  end

  @spec response(Conn.t(), find_server) :: Conn.t()
  defp response(conn, {:error, reason}) do
    Logger.error("Failed to start a caching server: #{inspect(reason)}")
    Conn.resp(conn, 500, "Internal server error")
  end

  defp response(conn, :error) do
    Logger.error("Failed to start a caching server: unknown reason")
    Conn.resp(conn, 500, "Internal server error")
  end

  defp response(conn, pid) do
    pid
    |> Server.fetch()
    |> Plug.send_as_json(conn)
  end
end
