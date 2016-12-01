defmodule EmbedChat.Repo.Migrations.RenameUserlog do
  use Ecto.Migration

  def up do
    rename table(:user_logs), to: table(:tracks)
  end

  def down do
    rename table(:tracks), to: table(:user_logs)
  end
end
