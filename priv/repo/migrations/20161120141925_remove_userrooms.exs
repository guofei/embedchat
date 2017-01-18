defmodule EmbedChat.Repo.Migrations.RemoveUserrooms do
  use Ecto.Migration

  def up do
    drop table(:userrooms)
  end

  def down do
    create table(:userrooms) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :room_id, references(:rooms, on_delete: :delete_all)

      timestamps()
    end
    create index(:userrooms, [:user_id])
    create index(:userrooms, [:room_id])
  end
end
