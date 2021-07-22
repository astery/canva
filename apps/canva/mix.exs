defmodule Canva.MixProject do
  use Mix.Project

  def project do
    [
      app: :canva,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [
        benchmark: :test
      ],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # in all envs because is used for data generation
      {:stream_data, "~> 0.5"},
      {:benchee, "~> 1.0", only: :test}
    ]
  end

  defp aliases do
    [
      benchmark: ["run ./samples/canva_impls.exs"],
      setup: ["deps.get"]
    ]
  end
end
