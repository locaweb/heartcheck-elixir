defmodule HeartCheck.Mixfile do
  use Mix.Project

  def version do
    "0.4.3"
  end

  def project do [app: :heartcheck,
     version: version(),
     description: "Web based monitoring/health checks",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     package: package(),
     source_url: "https://github.com/locaweb/heartcheck-elixir",
     homepage_url: "https://developer.locaweb.com.br/",
     docs: [
       main: "readme",
       logo: "logo.png",
       extras: ["README.md", "CONTRIBUTING.md", "LICENSE.md"],
     ],
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test, "coveralls.detail": :test,
       "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger]]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md",
              "CONTRIBUTING.md"],
      maintainers: ["Locaweb"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/locaweb/heartcheck-elixir",
               "Docs" => "https://hexdocs.pm/heartcheck/#{version()}"}]
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
      {:jason, "~> 1.0", optional: true},
      {:plug, "~> 1.0"},
      {:plug_cowboy, "~> 2.0", only: [:dev, :test]},
      {:httpoison, "~> 0.10 or ~> 1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.11", only: :dev, runtime: false},
      {:earmark, "~> 1.0", only: :dev},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.5", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
