defmodule EmbedChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :message_type, :string
      add :subject, :string
      add :body, :text
      add :incoming_id, references(:addresses, on_delete: :nothing), null: false
      add :outgoing_id, references(:addresses, on_delete: :nothing), null: false

      timestamps
    end
    create index(:messages, [:incoming_id])
    create index(:messages, [:outgoing_id])

  end
end
