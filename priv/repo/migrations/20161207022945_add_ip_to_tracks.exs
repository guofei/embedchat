defmodule EmbedChat.Repo.Migrations.AddIpToTracks do
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      add :ip, :string
    end
  end
end
