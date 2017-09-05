use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :embed_chat, EmbedChatWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["../assets/node_modules/webpack/bin/webpack.js",
                    "--watch-stdin", "--progress", "--colors",
                    cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
config :embed_chat, EmbedChatWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/embed_chat_web/views/.*(ex)$},
      ~r{lib/embed_chat_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :embed_chat, EmbedChat.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "embed_chat_dev",
  hostname: "localhost",
  pool_size: 10

config :embed_chat, EmbedChat.Mailer,
  adapter: Bamboo.LocalAdapter
