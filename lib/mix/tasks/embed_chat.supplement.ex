defmodule Mix.Tasks.EmbedChat.Supplement do
  use Mix.Task

  def run(_args) do
    Mix.Task.run "app.start"
    Mix.shell.info "start..."
    user_rooms = EmbedChat.Repo.all(EmbedChat.UserRoom)
    user_rooms |> Enum.each(fn(user_room) ->
      user_room =
        user_room
        |> EmbedChat.Repo.preload([:user, :room])
      user =
        user_room.user
        |> EmbedChat.Repo.preload(:projects)
      room = user_room.room
      # add project, add user project, add project id to room
      if Enum.empty?(user.projects) do
        project = EmbedChat.Repo.insert!(%EmbedChat.Project{})
        EmbedChat.Repo.insert(%EmbedChat.UserProject{user_id: user.id, project_id: project.id})
        changeset = EmbedChat.Room.changeset(room, %{"project_id" => project.id})
        EmbedChat.Repo.update(changeset)
      end
    end)
  end
end
