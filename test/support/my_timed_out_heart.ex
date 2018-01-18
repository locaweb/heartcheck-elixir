defmodule MyTimedOutHeart do
  @moduledoc false

  use HeartCheck, timeout: 50

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
    :timer.sleep(200)
    {:error, "failed"}
  end

  add(:module, MyTestModule)
end
