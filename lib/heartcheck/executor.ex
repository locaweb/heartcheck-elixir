defmodule HeartCheck.Executor do
  @moduledoc """

  Handles the execution of the checks in a HeartCheck module.

  Spawns several `Task`s for the checks, execute and wait for the result.

  Handles timeouts for the checks with the `{:error, "TIMEOUT"}` result.

  """

  require Logger

  @spec execute(HeartCheck) :: Keyword.t

  def execute(heartcheck) do
    checks = heartcheck.checks

    ref = make_ref

    :timer.send_after(heartcheck.timeout, self(), {ref, :timeout})

    checks
    |> Enum.map(fn(t) -> {t, make_task(t, heartcheck, ref)} end)
    |> recv(ref)
  end

  @spec make_task(atom, HeartCheck, reference) :: Task.t

  defp make_task(name, heartcheck, ref) do
    Task.async fn() ->
      log("(#{inspect(ref)}) Performing #{name}")
      {ref, name, :timer.tc(fn() -> apply(heartcheck, :perform_check, [name]) end)}
    end
  end

  @spec recv([atom], reference()) :: Keyword.t

  defp recv(checks, ref) do
    recv(checks, Enum.map(checks, fn({name, _}) -> {name, {0 ,{:error, "TIMEOUT"}}} end), ref)
  end

  @spec recv([atom], Keyword.t, reference()) :: Keyword.t

  defp recv([], results, _ref) do
    results
  end

  defp recv(checks, results, ref) do
    receive do
      {_, {^ref, name, {time, result}}} when is_reference(ref) ->
        log_result(name, ref, result, time)
        recv(Keyword.delete(checks, name), Keyword.put(results, name, {time, result}), ref)

      {^ref, :timeout} ->
        log("#{inspect(ref)} Execution timed out")
        results
    end
  end

  @spec log_result(atom, reference, :ok | {:error, String.t}, integer) :: :ok | {:error, term}

  defp log_result(name, ref, :ok, time) do
    log("#{inspect(ref)} #{name}: OK - Time: #{time}")
  end

  defp log_result(name, ref, {:error, reason}, time) do
    log("#{inspect(ref)} #{name}: ERROR: #{inspect(reason)} Time: #{time}")
  end

  @spec log(String.t) :: :ok | {:error, term}

  defp log(message) do
    Logger.info("[HeartCheck] #{message}")
  end
end
