defmodule HeartCheck.CachingPlug.Server do
  @moduledoc """
  GenServer that serves health check results from it's internal state
  """

  use GenServer

  require Logger

  import HeartCheck.Plug, only: [execute: 1]

  @default_name __MODULE__

  @doc """
  Starts a server that caches the given `heartcheck` module result for the
  given `ttl` (in milliseconds). It registers itself using the provided `name`.
  If name is not given, a name based on the `heartcheck` will be used.
  """
  @spec start_link(atom, non_neg_integer, GenServer.name) :: GenServer.on_start
  def start_link(heartcheck, ttl, name \\ nil) do
    server_name =
      case name do
        nil -> compose_name(heartcheck)
        _ -> name
      end

    GenServer.start_link(__MODULE__, [heartcheck, ttl], name: server_name)
  end

  @doc "Fetches the execution result from the cache"
  @spec fetch(GenServer.server) :: term
  def fetch(name) do
    GenServer.call(name, :fetch)
  end

  @doc "Returns the last time the server has run or `nil` if that didn't happen"
  @spec last_run(GenServer.server) :: DateTime.t | nil
  def last_run(name) do
    GenServer.call(name, :last_run)
  end

  def init([check, ttl]) do
    Logger.info("Caching plug for #{inspect(check)} server initialized")
    schedule(0)

    {:ok, %{ttl: ttl, last_run: nil, check: check, result: ""}}
  end

  def handle_call(:last_run, _from, state = %{last_run: last_run}) do
    {:reply, last_run, state}
  end

  def handle_call(:fetch, _from, state = %{result: result}) do
    {:reply, result, state}
  end

  def handle_info(:execute, state = %{ttl: ttl, check: check}) do
    Logger.info("Caching plug for #{inspect(check)} refreshing")

    new_result = execute(check)
    now = DateTime.utc_now()
    schedule(ttl)

    {:noreply, Map.merge(state, %{result: new_result, last_run: now})}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  @spec schedule(non_neg_integer) :: none
  defp schedule(interval) do
    :timer.send_after(interval, :execute)
  end

  @spec compose_name(atom) :: atom
  defp compose_name(name) do
    Module.concat(@default_name, name)
  end
end
