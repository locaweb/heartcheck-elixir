defmodule HeartCheck.Check do 
  @callback call() :: :ok | {:error, String.t}
end
