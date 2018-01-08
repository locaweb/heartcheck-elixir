defmodule TestRouter do
  @moduledoc false

  use Plug.Router

  require HeartCheck

  plug :match
  plug :dispatch

  forward "/monitoring", to: HeartCheck.Plug, heartcheck: MyHeart,
    functional: MyFunctionalHeart

  forward "/non-functional", to: HeartCheck.Plug, heartcheck: MyHeart

  forward "/caching", to: HeartCheck.CachingPlug, heartcheck: MyHeart,
    functional: MyFunctionalHeart
end
