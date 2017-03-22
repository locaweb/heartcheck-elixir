defmodule MyTestModule do
  @moduledoc false

  @behaviour HeartCheck.Check

  def call do
    :ok
  end
end
