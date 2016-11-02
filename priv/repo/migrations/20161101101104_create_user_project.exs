defmodule EmbedChat.Repo.Migrations.CreateUserProject do
  use Ecto.Migration

  def change do
    create table(:userprojects) do
      add :user_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end
    create index(:userprojects, [:user_id])
    create index(:userprojects, [:project_id])

  end
end
