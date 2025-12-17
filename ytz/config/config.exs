import Config

# Configure the application
config :ytz,
  port: 4000

# Import environment specific config
import_config "#{config_env()}.exs"
