use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :embed_chat, EmbedChatWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :embed_chat, EmbedChat.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "embed_chat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :bcrypt_elixir, :log_rounds, 4

config :embed_chat, EmbedChat.Mailer,
  adapter: Bamboo.LocalAdapter
