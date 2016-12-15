defmodule HeartCheck do
  @moduledoc """

  Define your own checks using this macro:

  ```elixir

  defmodule MyHeart do
    use HeartCheck, timeout: 2000 # 3000 is default

    add :redis do
      # TODO: do some actual checks here
      :ok
    end

    add :cas do
      # TODO: do some actual checks here
      :timer.sleep(2000)
      {:error, "something went wrong"}
    end

    # you can use modules that implement the `HeartCheck.Check` behaviour too:
    add :module_check, MyTestModule
  end

  ```

  In the example above, `MyTestModule` can be something like:

  ```
  defmodule MyTestModule do
    @behaviour HeartCheck.Check

    def call do
      # TODO: perform some actual checks here
      :ok
    end
  end
  ```

  """

  @typedoc "Return format for heartcheck checks"
  @type result :: :ok | {:error, String.t}

  defmacro __using__(opts) do
    quote do
      import HeartCheck
      @before_compile HeartCheck

      Module.register_attribute(__MODULE__, :checks, accumulate: true)

      def timeout do
        unquote(Keyword.get(opts, :timeout, 3000))
      end
    end
  end

  @spec add(:atom | String.t, [do: (() -> HeartCheck.result)] | HeartCheck.Check) :: :ok

  @doc """
  Adds a check to your heartcheck module.

  The check is identified by `name` (will be symbolized).

  The check itself may be described by a functioni in the `do` block or in an external module.

  The function or external module return value must conform to the `result` type by returning either `:ok` or `{:error, String.t}`

  """

  defmacro add(check, do: check_fn) do
    check_name = :"#{check}"

    quote do
      @checks unquote(check_name)
      def perform_check(unquote(check_name)), do: unquote(check_fn)
    end
  end


  defmacro add(check, mod) do
    check_name = :"#{check}"

    quote do
      @checks unquote(check_name)
      def perform_check(unquote(check_name)), do: unquote(mod).call
    end
  end

  defmacro check_name(name) when is_binary(name), do: String.to_atom(name)
  defmacro check_name(name) when is_atom(name), do: name
  defmacro check_name(name), do: :"#{name}"

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      @spec checks :: [atom]
      @doc "Returns a list of the registered checks"
      def checks, do: @checks

      @spec perform_check(atom) :: HeartCheck.result
      @doc "Performs the check defined by the atom"
      def perform_check(check), do: {:error, "undefined check: #{inspect(check)}"}
    end
  end
end
