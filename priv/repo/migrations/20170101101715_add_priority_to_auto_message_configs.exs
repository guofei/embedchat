defmodule EmbedChat.Repo.Migrations.AddPriorityToAutoMessageConfigs do
  use Ecto.Migration

  def change do
    alter table(:auto_message_configs) do
      add :priority, :integer, default: 10
    end
    create index(:auto_message_configs, [:priority])
  end
end
