defmodule HeartCheck.Formatter do
  @moduledoc """
  Formatter for more poison and heartcheck pattern friendly results
  """

  @doc """
  Formats results produced by `Executor.execute/1`
  """
  @spec format({String.t, {term, :ok} | {term, {:error, term}} | {term, :error}}) :: String.t
  def format({name, {time, :ok}}) do
    %{name => %{status: :ok}, time: time / 1000}
  end

  def format({name, {time, :error}}) do
    format({name, {time, {:error, "UNKOWN ERROR"}}})
  end

  def format({name, {time, {:error, reason}}}) do
    %{name => %{
      status: :error,
      message: [%{
        type: :error,
        message: reason
      }]},
      time: time / 1000
    }
  end
end
