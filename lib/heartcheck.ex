defmodule HeartCheck do
  @moduledoc """

  Define your own checks using this macro:

  ```elixir

  defmodule MyHeart do
    use HeartCheck, timeout: 2000 # 3000 is default

    add :redis do
      # TODO: do some actual tests here
      :ok
    end

    add :cas do
      # TODO: do some actual tests here
      :timer.sleep(2000)
      {:error, "something went wrong"}
    end

    # you can use modules that implement the `HeartCheck.Check` behaviour too:
    add :module, MyTestModule
  end

  ```

  In the example above, `MyTestModule` can be something like:

  ```
  defmodule MyTestModule do
    @behaviour HeartCheck.Check

    def call do
      # TODO: perform some actual tests here
      :ok
    end
  end
  ```

  """

  @typedoc "Returned format for heartcheck tests"
  @type result :: :ok | {:error, String.t}

  defmacro __using__(opts) do
    quote do
      import HeartCheck
      @before_compile HeartCheck

      Module.register_attribute(__MODULE__, :tests, accumulate: true)

      def timeout do
        unquote(Keyword.get(opts, :timeout, 3000))
      end
    end
  end

  @spec add(:atom | String.t, [do: (() -> result)] | HeartCheck.Check) :: :ok

  defmacro add(test, do: test_fn) do
    quote do
      @tests unquote(test)
      def perform_test(unquote(:"#{test}")) do
        unquote(test_fn)
      end
    end
  end

  defmacro add(test, mod) do
    quote do
      @tests unquote(test)
      def perform_test(unquote(:"#{test}")) do
        unquote(mod).call
      end
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    mod_tests = Module.get_attribute(env.module, :tests)

    quote do
      def tests, do: unquote(mod_tests)

      def perform_test(test), do: {:error, "undefined test: #{inspect(test)}"}
    end
  end
end
