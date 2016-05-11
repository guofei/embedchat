defmodule EmbedChat.Repo.Migrations.CreateAutoMessageConfig do
  use Ecto.Migration

  def change do
    create table(:auto_message_configs) do
      add :delay_time, :integer
      add :current_url, :string
      add :referrer, :string
      add :language, :string

      timestamps
    end

  end
end
