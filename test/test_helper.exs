ExUnit.start

Mix.Task.run "ecto.create", ~w(-r EmbedChat.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r EmbedChat.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(EmbedChat.Repo)

