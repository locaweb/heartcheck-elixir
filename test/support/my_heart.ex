defmodule MyHeart do
  @moduledoc false

  use HeartCheck, timeout: 1000

  add :redis do
    :ok
  end

  add "string_test" do
    :ok
  end

  add :failing do
    {:error, "I always fail"}
  end

  add :cas do
    {:error, "failed"}
  end

  add :module, MyTestModule
end
