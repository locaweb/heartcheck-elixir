defmodule MyTestModule do
  @behaviour HeartCheck.Check

  def call do
    :ok
  end
end
