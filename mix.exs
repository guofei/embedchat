defmodule EmbedChat.Mixfile do
  use Mix.Project

  def project do
    [app: :embed_chat,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {EmbedChat, []},
     # :elixometer, :exometer must before at phoenix.
     # see: https://groups.google.com/forum/#!topic/elixir-lang-talk/aulK9E4Hxk8
     applications: [:elixometer, :exometer,
                    :phoenix, :phoenix_html, :phoenix_pubsub, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :comeonin, :hound]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:comeonin, "~> 2.5"},
     {:cowboy, "~> 1.0"},
     {:credo, "~> 0.4", only: [:dev, :test]},
     # exometer start
     {:elixometer, "~>1.2"},
     {:exometer_core, github: "PSPDFKit-Labs/exometer_core", override: true},
     {:exometer, github: "PSPDFKit-Labs/exometer", override: true},
     {:edown, "~> 0.8.1", override: true},
     {:lager, "~> 3.2", override: true},
     # exometer end
     {:exrm, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:hound, "~> 1.0"},
     {:mailgun, "~> 0.1.2"},
     {:phoenix, "~> 1.2"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_pubsub, "~> 1.0"},
     {:poison, "~> 2.2", override: true},
     {:postgrex, "~> 0.11"},
     {:scrivener_ecto, "~> 1.0"},
     {:scrivener_html, "~> 1.3"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
