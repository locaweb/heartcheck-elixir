defmodule HeartCheck.Check do
  @moduledoc """
  Behaviour for modules that can be added as a check in `HeartCheck.add/2`
  """

  @callback call() :: :ok | {:error, String.t}
end
