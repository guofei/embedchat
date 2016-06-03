defmodule EmbedChat.Repo.Migrations.AddSinglePvAndTotalPvToAutoMessageConfig do
  use Ecto.Migration

  def change do
    alter table(:auto_message_configs) do
      add :single_page_view, :integer
      add :single_page_view_pattern, :string
      add :total_page_view, :integer
      add :total_page_view_pattern, :string
    end
  end
end
