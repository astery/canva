use Mix.Config

# We don't run a server during test
config :canva_service_web, CanvaServiceWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

config :canva_files, module: CanvaFiles.MemoryStorage
