defmodule EmbedChat.Repo.Migrations.ChangeAddressIndex do
  use Ecto.Migration

  def change do
    drop index(:addresses, [:uuid])
    create index(:addresses, [:uuid, :room_id])
  end
end
