defmodule HeartCheck.Plug do
  @moduledoc """
  Plug to mount heartcheck in your plug-compatible app

  Add to your router:

  ```elixir

  def MyApp.Router
  use Plug.Router
  # (...)
  forward "/monitoring", to: HeartCheck.Plug, heartcheck: MyHeart
  end

  ```

  Or phoenix pipeline (note the different syntax):

  ```elixir

  def MyApp.Router
  use MyApp.Web, :router

  # (...)

  scope "/", MyApp do
  pipe_through :browser

  # (...)

  forward "/monitoring", HeartCheck.Plug, heartcheck: MyHeart
  end
  end

  ```
  """

  require Logger
  import Plug.Conn

  @spec init(term) :: term
  def init(options), do: options

  @spec call(Plug.Conn.t, term) :: Plug.Conn.t

  def call(conn = %Plug.Conn{path_info: ["health_check"]}, _) do
    %{status: :ok}
    |> Poison.encode!
    |> send_as_json(conn)
  end

  def call(conn = %Plug.Conn{path_info: []}, [heartcheck: heartcheck]) do
    heartcheck
    |> HeartCheck.Executor.execute
    |> Enum.map(&HeartCheck.Formatter.format/1)
    |> Poison.encode!
    |> send_as_json(conn)
  end

  def call(conn, _options) do
    conn |> send_resp(404, "not found") |> halt
  end

  defp send_as_json(body, conn) do
    conn 
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, body)
    |> halt
  end
end
