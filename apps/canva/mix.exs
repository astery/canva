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
end
