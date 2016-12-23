defmodule EmbedChat.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :content, :text

      timestamps()
    end

  end
end
