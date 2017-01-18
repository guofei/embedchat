defmodule EmbedChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :from_id, references(:addresses, on_delete: :nothing), null: false
      add :to_id, references(:addresses, on_delete: :nothing)

      timestamps()
    end
    create index(:messages, [:from_id])
    create index(:messages, [:to_id])

  end
end
