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

## Running tests and metrics:

To run the tests, simply execute:

```
$ mix test
```

To run coverage metrics and generate a html report:

```
$ mix coveralls.html
```
