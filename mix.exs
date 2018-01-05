defmodule HeartCheck.Mixfile do
  use Mix.Project

  def project do [app: :heartcheck,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     source_url: "https://github.com/locaweb/heartcheck-elixir",
     homepage_url: "http://developer.locaweb.com.br/",
     docs: [
       logo: "logo.png",
       extras: ["README.md", "CONTRIBUTING.md"],
     ],
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test,
       "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 2.0 or ~> 3.0"},
      {:plug, "~> 1.0"},
      {:cowboy, "~> 1.0", only: [:dev, :test]},
      {:httpoison, "~> 0.10", only: [:dev, :test]},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 1.0", only: :dev},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.5", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
