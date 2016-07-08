defmodule EmbedChat.Repo.Migrations.CreateUserLog do
  use Ecto.Migration

  def change do
    create table(:user_logs) do
      add :agent, :string
      add :href, :string
      add :referrer, :string
      add :screen_width, :string
      add :screen_height, :string
      add :language, :string
      add :visit_view, :string
      add :single_page_view, :string
      add :total_page_view, :string
      add :location, :string
      add :address_id, references(:addresses, on_delete: :nothing)

      timestamps()
    end
    create index(:user_logs, [:address_id])

  end
end
