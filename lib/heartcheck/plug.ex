defmodule HeartCheck.Plug do
  @moduledoc """
  Plug to mount heartcheck in your plug-compatible app

  Add to your router:

  ```elixir

  def MyApp.Router
    use Plug.Router
    # (...)
    plug :HeartCheck.Plug
  end

  ```

  Or phoenix pipeline:

  ```elixir

  def MyApp.Router
    use MyApp.Web, :router

    pipeline :api do
      # (...)
      plug :HeartCheck.Plug
    end
  end

  ```
  """

  @spec init(term) :: term
  def init(options), do: options

  @spec call(Plug.Conn.t, term) :: Plug.Conn.t

  def call(conn, options) do
    at = Keyword.get(options, :at)
    heartcheck = Keyword.get(options, :heartcheck)

    if at == conn.request_path do
      body =
        heartcheck
        |> HeartCheck.Executor.execute
        |> Enum.map(&HeartCheck.Formatter.format/1)
        |> Poison.encode!

      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(200, body)
      |> Plug.Conn.halt
    else
      conn
    end
  end
end
