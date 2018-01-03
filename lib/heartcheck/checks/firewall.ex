defmodule HeartCheck.Checks.Firewall do

  def validate(urls) when is_list(urls) do
    errors = Enum.flat_map(urls, fn url ->
      case execute_validate(url) do
        {:error, msg} -> [msg]
        :ok -> []
      end
    end)

    case length(errors) do
      0 -> :ok
      _ -> {:error, errors}
    end
  end

  def validate(url) when is_binary(url), do: execute_validate(url)

  defp execute_validate(url) do
    %URI{host: host, port: port} = URI.parse(url)

    case :gen_tcp.connect(String.to_charlist(host), port, [:binary, packet: 0, active: false], 2000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        :ok
      {:error, _} ->
        {:error, "Failed to connect to host [#{host}] on port [#{port}]"}
    end
  end
end
