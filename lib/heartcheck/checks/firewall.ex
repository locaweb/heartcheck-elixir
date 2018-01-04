defmodule HeartCheck.Checks.Firewall do
  @moduledoc """
  A module that provides a way to check connection
  availability to external services
  """

  @timeout 1000
  def validate(urls, options \\ [])

  @spec validate(String.t, Keyword.t) :: :ok | {:error, list}
  def validate(urls, options) when is_list(urls) do
    errors =
      urls
        |> Enum.map(&(execute_validate(&1, options)))
        |> Enum.reject(&(&1 == :ok))
        |> Enum.map(fn({:error, msg}) -> msg end)

    case length(errors) do
      0 -> :ok
      _ -> {:error, errors}
    end
  end

  @spec validate(String.t, Keyword.t) :: :ok | {:error, String.t}
  def validate(url, options) when is_binary(url), do: execute_validate(url, options)

  defp execute_validate(url, options) do
    %URI{host: host, port: port} = URI.parse(url)
    timeout = Keyword.get(options, :timeout, @timeout)

    case :gen_tcp.connect(String.to_charlist(host), port, [], timeout) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        :ok
      {:error, _} ->
        {:error, "Failed to connect to host [#{host}] on port [#{port}]"}
    end
  end
end
