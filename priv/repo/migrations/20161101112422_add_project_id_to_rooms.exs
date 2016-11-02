defmodule EmbedChat.Repo.Migrations.AddProjectIdToRooms do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :project_id, references(:projects, on_delete: :nothing)
    end
    create index(:rooms, [:project_id])
  end
end
