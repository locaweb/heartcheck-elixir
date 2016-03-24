defmodule MyHeart do
  use HeartCheck

  add :redis do
    # TODO: do some actual tests here
    :ok
  end

  add :cas do
    # TODO: do some actual tests here
    IO.puts "aaa"
    :timer.sleep(2000)
    {:error, "failed"}
  end
end
