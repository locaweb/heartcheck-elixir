defmodule HeartCheck.Formatter do
  @moduledoc """
  Formatter for more poison and heartcheck pattern friendly results
  """

  @spec format({String.t, {term, :ok} | {term, {:error, term}}}) :: String.t

  def format({name, {time, :ok}}) do
    %{name => %{status: :ok}, time: time / 1000}
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
