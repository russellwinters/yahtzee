import Config

# We don't run a server during test.
config :phoenix, PhoenixWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "SECRET_KEY_BASE_FOR_TEST_ONLY",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning
