defmodule EmbedChat.Repo.Migrations.CreateRoom do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :uuid, :uuid

      timestamps
    end

  end
end
