defmodule EmbedChat.Repo.Migrations.AddVisitViewAndPatternsToAutoMessageConfig do
  use Ecto.Migration

  def change do
    alter table(:auto_message_configs) do
      add :message, :text
      add :visit_view, :integer
      add :current_url_pattern, :string
      add :referrer_pattern, :string
      add :language_pattern, :string
      add :visit_view_pattern, :string
    end
  end
end
