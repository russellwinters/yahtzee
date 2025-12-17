import Config

# Configures the endpoint
config :ytz, YtzWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: YtzWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ytz.PubSub,
  live_view: [signing_salt: System.get_env("LIVEVIEW_SIGNING_SALT") || "CHANGE_ME_IN_PRODUCTION_LIVEVIEW_SECRET"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config
import_config "#{config_env()}.exs"
