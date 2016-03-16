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
  def call(conn, _options) do
    conn
  end
end
