defmodule MyTimedOutHeart do
  @moduledoc false

  use HeartCheck, timeout: 50

  add :redis do
    # TODO: do some actual tests here
    :ok
  end

  add "string_test" do
    :ok
  end

  add :failing do
    {:error, "I always fail"}
  end

  add :cas do
    # TODO: do some actual tests here
    :timer.sleep(200)
    {:error, "failed"}
  end

  add :module, MyTestModule
end
