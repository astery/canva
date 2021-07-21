defmodule CanvaUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [
        benchmark: :test
      ],
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      benchmark: ["cmd --app canva mix benchmark"],
      setup: ["cmd mix setup"]
    ]
  end
end
