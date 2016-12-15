# HeartCheck

Checks your application health

## Installation

The package can be installed as:

  1. Add heartcheck to your list of dependencies in `mix.exs`:

        def deps do
          [{:heartcheck, "~> 1.0.0"}]
        end

  2. Ensure heartcheck is started before your application:

        def application do
          [applications: [:heartcheck]]
        end

## Usage

Define your checks in module by using the `HeartCheck` macro module and invoking the `add` macro:

```elixir

defmodule MyApp.HeartCheck do
  use HeartCheck

  add :some_check do
    # TODO: perform some actual check here
    :ok
  end

  add :another_check do
    # TODO: perform some actual check here
    {:error, "something went wrong"}
  end
end

```

Then you can mount `HeartCheck.Plug` using the module defined above in your app router (phoenix example below):

```elixir

def MyApp.Router
  use MyApp.Web, :router

  # (...)

  scope "/", MyApp do
    pipe_through :browser

    # (...)

    forward "/monitoring", HeartCheck.Plug, heartcheck: MyApp.HeartCheck
  end
end

```

Then your checks will be available at the `/monitoring` endpoint.

You can define a another module using `HeartCheck` and use it as your functional monitoring in the router:

```elixir
    forward "/monitoring", HeartCheck.Plug, heartcheck: MyApp.HeartCheck, functional: MyApp.FunctionalHeartCheck
```

This will be available in the `/monitoring/funcional` endpoint.

## Running tests and metrics:

To run the tests, simply execute:

```
$ mix test
```

To run coverage metrics and generate a html report:

```
$ mix coveralls.html
```
