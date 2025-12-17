import Config

# For development, we disable any cache
config :ytz, YtzWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: false
