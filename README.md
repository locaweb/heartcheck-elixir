# HeartCheck

Checks your application health

[![Build Status](https://travis-ci.org/locaweb/heartcheck-elixir.svg?branch=master)](https://travis-ci.org/locaweb/heartcheck-elixir)

## Installation

Add heartcheck to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [{:heartcheck, "~> 0.3.0"}]
  end
```

If you are using elixir < 1.5, ensure heartcheck is started before your
application:

```elixir
  def application do
    [applications: [:heartcheck]]
  end
```

## Usage

### Defining your checks

Define your checks in module by using the `HeartCheck` macro module and invoking
the `HeartCheck.add/2` macro:

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

The checks can return one of the following terms:

* `:ok`
* `{:error, term}`
* `:error`

In the `{error, term}` case, a representation of `term` will be used as the
error message.

### Mounting in your web app

Then you can mount `HeartCheck.Plug` using the module defined above in your app
router (phoenix example below):

```elixir
def MyApp.Router
  use MyApp.Web, :router

  # (...)

  scope "/" do
    pipe_through :browser

    # (...)

    forward "/monitoring", HeartCheck.Plug, heartcheck: MyApp.HeartCheck
  end
end

```

Then your checks will be available at the `/monitoring` endpoint.

You can define a another module using `HeartCheck` and use it as your functional
monitoring in the router:

```elixir
  forward "/monitoring", HeartCheck.Plug, heartcheck: MyApp.HeartCheck,
    functional: MyApp.FunctionalHeartCheck
```

This will be available in the `/monitoring/funcional` endpoint.

## Other checks

### Firewall Check

Use firewall check inside your heartcheck file to ensure your application is
able to connect to an external service. This will only open a TCP connection
to the defined host/port in the url and assert it can connect.

Timeout argument is optional and default is `1000` (1 second).

```elixir
defmodule MyApp.HeartCheck do
  use HeartCheck

  firewall(service: "http://service.acme.org:3200",
    another_service: Application.get_env(:my_app, :service_url))

  firewall(my_domain: Application.get_env(:my_app, :url), timeout: 2000)
end
```

## Running tests and metrics:

To run the tests, simply execute:

```
$ mix test
```

To run coverage metrics and generate a html report in `cover/excoveralls.html`:

```
$ mix coveralls.html
```
