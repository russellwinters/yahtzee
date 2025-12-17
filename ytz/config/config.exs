import Config

# Configure the endpoint
config :ytz, YtzWeb.Endpoint,
  http: [port: 4000],
  server: true

# Import environment specific config
import_config "#{config_env()}.exs"
