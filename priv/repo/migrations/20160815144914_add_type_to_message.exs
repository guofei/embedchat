defmodule EmbedChat.Repo.Migrations.AddTypeToMessage do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :type, :string, null: false, default: "normal"
    end
  end
end
