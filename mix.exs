defmodule Prospero.MixProject do
  use Mix.Project

  def project do
    [
      app: :prospero,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Josh Reinhardt"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jereinhardt/prospero"}
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:ecto, only: [:test]},
      {:jason, "~> 1.1", only: [:test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
