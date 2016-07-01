# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :embed_chat, EmbedChat.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "lMDLZpU9VELtV5xh7vKniLeEQkh0beFSS35y19OgwOv/Ie7mDCEfSqkE2xSYLsgN",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: EmbedChat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :embed_chat, ecto_repos: [EmbedChat.Repo]

config :embed_chat, EmbedChat.Gettext,
  locales: ~w(en ja)

config :hound, driver: "phantomjs"

config :scrivener_html,
  routes_helper: EmbedChat.Router.Helpers
