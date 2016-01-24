defmodule EmbedChat.Repo.Migrations.CreateRoom do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:rooms, [:user_id])

  end
end
