defmodule EmbedChat.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :content_en, :text
      add :content_ja, :text
      add :content_zh, :text

      timestamps()
    end

  end
end
