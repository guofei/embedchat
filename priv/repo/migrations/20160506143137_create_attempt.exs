defmodule EmbedChat.Repo.Migrations.CreateAttempt do
  use Ecto.Migration

  def change do
    create table(:attempts) do
      add :email, :string
      add :url, :string

      timestamps()
    end

  end
end
