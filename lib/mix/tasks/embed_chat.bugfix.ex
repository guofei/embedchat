defmodule Mix.Tasks.EmbedChat.Bugfix do
  use Mix.Task

  def run(_args) do
    Mix.Task.run "app.start"
    Mix.shell.info "start..."
    EmbedChat.Address
    |> EmbedChat.Repo.all
    |> Enum.each(fn(address) ->
      if address.room_id == 1 and address.user_id do
        if address.room_id != address.user_id do
          IO.inspect address.id
          changeset = EmbedChat.Address.changeset(address, %{"user_id" => nil})
          EmbedChat.Repo.update changeset
        end
      end
    end)
  end
end
