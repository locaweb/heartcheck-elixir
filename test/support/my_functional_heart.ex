defmodule MyFunctionalHeart do
  @moduledoc false

  use HeartCheck, timeout: 1000

  add :memcached do
    # TODO: do some actual tests here
    :ok
  end
end
