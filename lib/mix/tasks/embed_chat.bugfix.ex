defmodule Mix.Tasks.EmbedChat.Bugfix do
  use Mix.Task

  def run(_args) do
    Mix.Task.run "app.start"
    Mix.shell.info "start..."
  end
end
