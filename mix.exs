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
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :comeonin, :hound]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:comeonin, "~> 2.4"},
     {:cowboy, "~> 1.0"},
     {:exrm, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:hound, "~> 1.0"},
     {:phoenix, "~> 1.1"},
     {:phoenix_ecto, "~> 2.0"},
     {:phoenix_html, "~> 2.5"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:postgrex, "~> 0.11"},
     {:scrivener, "~> 1.0"},
     {:scrivener_html, "~> 1.1"},
     {:credo, "~> 0.3", only: [:dev, :test]}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
