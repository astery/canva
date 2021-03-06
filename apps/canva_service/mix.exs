defmodule CanvaService.MixProject do
  use Mix.Project

  def project do
    [
      app: :canva_service,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {CanvaService.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:canva, in_umbrella: true},
      {:canva_files, in_umbrella: true},
      {:phoenix_pubsub, "~> 2.0"},
      {:hammox, "~> 0.5", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
