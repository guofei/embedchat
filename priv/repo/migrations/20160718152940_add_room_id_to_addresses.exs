defmodule EmbedChat.Repo.Migrations.AddRoomIdToAddresses do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :room_id, references(:rooms, on_delete: :nothing)
    end
    drop index(:addresses, [:uuid])
    create index(:addresses, [:uuid])
    create index(:addresses, [:room_id])
  end
end
