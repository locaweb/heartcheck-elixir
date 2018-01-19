defmodule MyTestModule do
  @moduledoc false

  @behaviour HeartCheck.Check

  @impl HeartCheck.Check
  def call do
    :ok
  end
end
