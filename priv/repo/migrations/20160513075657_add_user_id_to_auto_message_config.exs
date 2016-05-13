defmodule EmbedChat.Repo.Migrations.AddUserIdToAutoMessageConfig do
  use Ecto.Migration

  def change do
    alter table(:auto_message_configs) do
      add :user_id, references(:users, on_delete: :nothing)
    end
    create index(:auto_message_configs, [:user_id])
  end
end
