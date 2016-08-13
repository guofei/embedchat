defmodule EmbedChat.Repo.Migrations.AddVisitorIdToAddress do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :visitor_id, references(:visitors, on_delete: :nothing)
    end
    create index(:addresses, [:visitor_id])
  end
end
