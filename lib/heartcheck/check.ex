defmodule HeartCheck.Check do
  @moduledoc """
  Behaviour for modules that can be added as a check in `HeartCheck.add/2`
  """

  @doc """
  Function that performs the test itself
  """
  @callback call() :: HeartCheck.result()
end
