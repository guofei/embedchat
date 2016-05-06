defmodule EmbedChat.Repo.Migrations.AddIndexToRoomUuid do
  use Ecto.Migration

  def change do
    create index(:rooms, [:uuid])
  end
end
