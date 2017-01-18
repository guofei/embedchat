defmodule EmbedChat.Repo.Migrations.CreateUserRoom do
  use Ecto.Migration

  def change do
    create table(:userrooms) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :room_id, references(:rooms, on_delete: :delete_all)

      timestamps()
    end
    create index(:userrooms, [:user_id])
    create index(:userrooms, [:room_id])

  end
end
