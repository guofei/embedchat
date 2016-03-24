defmodule EmbedChat.Repo.Migrations.AddRoomIdToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :room_id, references(:rooms, on_delete: :nothing)
    end
    create index(:messages, [:room_id])
  end
end
