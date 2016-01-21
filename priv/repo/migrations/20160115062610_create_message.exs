defmodule EmbedChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :message_type, :string
      add :subject, :string
      add :body, :text
      add :from_address_id, references(:addresses, on_delete: :nothing), null: false
      add :to_address_id, references(:addresses, on_delete: :nothing), null: false

      timestamps
    end
    create index(:messages, [:from_address_id])
    create index(:messages, [:to_address_id])

  end
end
