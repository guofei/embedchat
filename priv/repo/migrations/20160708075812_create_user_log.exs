defmodule EmbedChat.Repo.Migrations.CreateUserLog do
  use Ecto.Migration

  def change do
    create table(:user_logs) do
      add :agent, :string
      add :current_url, :string
      add :referrer, :string
      add :screen_width, :integer
      add :screen_height, :integer
      add :language, :string
      add :visit_view, :integer
      add :single_page_view, :integer
      add :total_page_view, :integer
      add :location, :string
      add :address_id, references(:addresses, on_delete: :nothing)

      timestamps()
    end
    create index(:user_logs, [:address_id])

  end
end
