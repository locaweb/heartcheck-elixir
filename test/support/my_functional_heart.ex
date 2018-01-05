defmodule MyFunctionalHeart do
  @moduledoc false

  use HeartCheck, timeout: 1000

  add :memcached do
    :ok
  end
end
