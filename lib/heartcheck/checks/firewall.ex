defmodule HeartCheck.Checks.Firewall do
  @moduledoc """
  A module that provides a way to check connection
  availability to external services
  """

  @timeout 1000

  @spec validate(String.t, Keyword.t) ::
    :ok | {:error, String | list}
  def validate(url, options \\ []) do
    do_validate(url, options)
  end

  defp do_validate(url, options) do
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
