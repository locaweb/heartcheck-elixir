defmodule HeartCheck do
  @moduledoc """
  """

  defmacro __using__(opts) do
    quote do
      import HeartCheck
      @before_compile HeartCheck

      Module.register_attribute(__MODULE__, :tests, accumulate: true)
    end
  end

  defmacro add(test, test_fn) do
    quote do
      @tests unquote(test)

      def unquote(:"perform_test_#{test}")() do
        unquote(test_fn).()
      end
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    mod_tests = Module.get_attribute(env.module, :tests)

    quote do
      def tests, do: unquote(mod_tests)
    end
  end
end

defmodule MyHeart do
  use HeartCheck

  add :redis, fn() ->
    {:error, "não deu certo"}
  end

  add :cas, fn() ->
    :timer.sleep(2000)
    :ok
  end
end
