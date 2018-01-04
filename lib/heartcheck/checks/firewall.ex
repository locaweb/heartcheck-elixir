defmodule HeartCheck.Checks.Firewall do
  @moduledoc """
  A module that provides a way to check connection
  availability to external services
  """

  @timeout 2000

  @spec validate(String.t) :: :ok | {:error, list}
  def validate(urls) when is_list(urls) do
    errors =
      Enum.map(urls, &execute_validate/1)
      |> Enum.map(fn({_, error}) -> error end)
      |> Enum.reject(&is_nil/1)

    case length(errors) do
      0 -> :ok
      _ -> {:error, errors}
    end
  end

  @spec validate(String.t) :: :ok | {:error, String.t}
  def validate(url) when is_binary(url) do
    case execute_validate(url) do
      {:ok, nil} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  defp execute_validate(url) do
    %URI{host: host, port: port} = URI.parse(url)

    case :gen_tcp.connect(String.to_charlist(host), port, [], @timeout) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        { :ok, nil }
      {:error, _} ->
        {:error, "Failed to connect to host [#{host}] on port [#{port}]"}
    end
  end
end
