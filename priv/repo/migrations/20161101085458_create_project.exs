defmodule EmbedChat.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :domain, :string
      add :name, :string

      timestamps()
    end

  end
end
