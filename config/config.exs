# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :canva_service_web,
  generators: [context_app: :canva_service]

# Configures the endpoint
config :canva_service_web, CanvaServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XemC1gDWCvTp9C41DgKC++dkzDipA1D6YIZgPc42WpZ/2Sc6pTUhmwyznj0ooxB+",
  render_errors: [view: CanvaServiceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CanvaService.PubSub,
  live_view: [signing_salt: "EifR9p4Q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nanoid,
  alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
