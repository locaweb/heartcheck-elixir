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

    @impl HeartCheck.Check
    def call do
      # TODO: perform some actual checks here
      :ok
    end
  end
  ```

  """

  alias HeartCheck.Checks.Firewall

  @typedoc "Return format for heartcheck checks"
  @type result :: :ok | {:error, String.t()} | :error

  @doc """
  Returns the list of the names of checks performed by this HeartCheck module
  """
  @callback checks() :: [atom]

  @doc "Returns the timeout in milliseconds for running all the checks"
  @callback timeout() :: non_neg_integer

  @doc "Performs the check identifier by `name`"
  @callback perform_check(name :: atom) :: result

  @doc """
  Adds HeartCheck support for your module.

  You may define the timeout (in milliseconds) for the overall checks using the
  `timeout` option.

  """
  @spec __using__(Keyword.t()) :: Macro.t()
  defmacro __using__(opts) do
    quote do
      import HeartCheck

      @behaviour HeartCheck

      @before_compile HeartCheck

      Module.register_attribute(__MODULE__, :checks, accumulate: true)

      def timeout do
        unquote(Keyword.get(opts, :timeout, 3000))
      end
    end
  end

  @doc """
  Adds a check to your heartcheck module.

  The check is identified by `name` (will be converted to an atom).

  The check itself may be described by a function in the `do` block or in an
  external module.

  The function or external module return value must conform to the `result` type
  by returning either `:ok`, `:error` or `{:error, String.t}`

  """
  @spec add(:atom | String.t(), [do: (() -> HeartCheck.result())] | HeartCheck.Check) :: Macro.t()
  defmacro add(check, do: check_fn) do
    check_name = check_name(check)

    quote do
      @checks unquote(check_name)
      def perform_check(unquote(check_name)), do: unquote(check_fn)
    end
  end

  defmacro add(check, mod) do
    check_name = check_name(check)

    quote do
      @checks unquote(check_name)
      def perform_check(unquote(check_name)), do: unquote(mod).call
    end
  end

  @doc """
  Add firewall checks to your external services using a keyword list.

  Keys are used for the check names and the values are evaluated in runtime to
  obtain the url to check. Options such as `timeout` can be merged with the list
  of URLs to check.

  """
  @spec firewall(Keyword.t()) :: Macro.t()
  defmacro firewall(opts) do
    option_keys = [:timeout]

    {options, urls} = Keyword.split(opts, option_keys)

    Enum.map(urls, fn {name, check} ->
      quote do
        add unquote(name) do
          Firewall.validate(unquote(check), unquote(options))
        end
      end
    end)
  end

  @doc """
  Add firewall checks to your external services using a list with `name` and
  `url`.

  Optionally accepts a keyword list of options. Currently, the only option
  available is `timeout`.

  """
  @spec firewall(String.t() | atom, String.t() | term(), Keyword.t()) :: Macro.t()
  defmacro firewall(name, url, opts \\ []) do
    quote do
      add unquote(name) do
        Firewall.validate(unquote(url), unquote(opts))
      end
    end
  end

  @doc false
  @spec check_name(String.t() | atom) :: Macro.t()
  def check_name(name) when is_binary(name), do: String.to_atom(name)
  def check_name(name) when is_atom(name), do: name

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def checks, do: @checks

      def perform_check(check) do
        {:error, "undefined check: #{inspect(check)}"}
      end
    end
  end
end
