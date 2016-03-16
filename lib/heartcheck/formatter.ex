defmodule HeartCheck.Formatter do
  @moduledoc """
  Formatter for more poison and heartcheck pattern friendly results
  """

  @spec format({String.t, :ok | {:error, term}}) :: String.t

  def format({name, :ok}) do
    %{name => %{status: :ok}}
  end

  def format({name, {:error, reason}}) do
    %{name => %{
      status: :error,
      message: [%{
        type: :error,
        message: reason
      }]
    }}
  end
end
