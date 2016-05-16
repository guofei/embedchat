defmodule EmbedChat.Repo.Migrations.AddRoomIdToAutoMessageConfig do
  use Ecto.Migration

  def change do
    alter table(:auto_message_configs) do
      add :room_id, references(:rooms, on_delete: :nothing)
    end
    create index(:auto_message_configs, [:room_id])
  end
end
