defmodule EmbedChat.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :uuid, :uuid
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:addresses, [:user_id])
    create index(:addresses, [:uuid])

  end
end
