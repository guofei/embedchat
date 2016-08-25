defmodule EmbedChat.Repo.Migrations.AddIndexToVisitorEmail do
  use Ecto.Migration

  def change do
    create index(:visitors, [:email])
  end
end
