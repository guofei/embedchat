defmodule EmbedChat.Repo.Migrations.CreateVisitor do
  use Ecto.Migration

  def change do
    create table(:visitors) do
      add :name, :string
      add :email, :string
      add :note, :text

      timestamps()
    end

  end
end
