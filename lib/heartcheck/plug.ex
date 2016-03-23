defmodule HeartCheck.Plug do
  @moduledoc """
  Plug to mount heartcheck in your plug-compatible app

  Add to your router:

  ```elixir

  def MyApp.Router
    use Plug.Router
    # (...)
    plug :HeartCheck.Plug, at: "/monitoring", heartcheck: MyHeart
  end

  ```

  Or phoenix pipeline:

  ```elixir

  def MyApp.Router
    use MyApp.Web, :router

    pipeline :api do
      # (...)
      plug :HeartCheck.Plug, at: "/monitoring", heartcheck: MyHeart
    end
  end

  ```
  """

  @spec init(term) :: term
  def init(options), do: options

  @spec call(Plug.Conn.t, term) :: Plug.Conn.t

  def call(conn = %Plug.Conn{request_path: at}, [at: at, heartcheck: heartcheck]) do
    body =
      heartcheck
      |> HeartCheck.Executor.execute
      |> Enum.map(&HeartCheck.Formatter.format/1)
      |> Poison.encode!

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(200, body)
    |> Plug.Conn.halt
  end

  def call(conn, _options), do: conn
end
