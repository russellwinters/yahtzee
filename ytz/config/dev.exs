import Config

# For development, we disable any cache and enable
# debugging and code reloading.
config :ytz, YtzWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "dev_secret_key_base_that_is_at_least_64_bytes_long_for_development",
  watchers: []

# Watch static and templates for browser reloading.
config :ytz, YtzWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/ytz_web/(live|views)/.*(ex)$",
      ~r"lib/ytz_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
