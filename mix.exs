defmodule HeartCheck.Mixfile do
  use Mix.Project

  @source_url "https://github.com/locaweb/heartcheck-elixir"
  @version "0.4.3"

  def project do
    [
      app: :heartcheck,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def package do
    [
      description: "Web based monitoring/health checks",
      files: ["lib", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md", "CONTRIBUTING.md"],
      maintainers: ["Locaweb"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/heartcheck/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  defp deps do
    [
      {:jason, "~> 1.0", optional: true},
      {:plug, "~> 1.0"},
      {:plug_cowboy, "~> 2.0", only: [:dev, :test]},
      {:httpoison, "~> 0.10 or ~> 1.0", only: [:dev, :test]},
      {:ex_doc, "> 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.15", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "CONTRIBUTING.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      homepage_url: "https://developer.locaweb.com.br/",
      logo: "logo.png"
    ]
  end
end
