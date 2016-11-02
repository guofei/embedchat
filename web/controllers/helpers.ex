defmodule EmbedChat.Helpers do
  alias EmbedChat.Repo
  alias EmbedChat.UserProject
  alias EmbedChat.Project
  alias EmbedChat.Room

  def user_rooms(conn) do
    conn.assigns.current_user |> Ecto.assoc(:rooms)
  end

  def create_project(user) do
    {:ok, project} = Repo.insert(%Project{})
    Repo.insert(%UserProject{user_id: user.id, project_id: project.id})
    Repo.insert(%Room{uuid: Ecto.UUID.generate(), project_id: project.id})
  end
end
