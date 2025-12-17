import Config

# Configures the endpoint
config :phoenix, PhoenixWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PhoenixWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Phoenix.PubSub,
  live_view: [signing_salt: "SECRET_SALT"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config
import_config "#{config_env()}.exs"
