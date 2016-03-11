defmodule EmbedChat.UserController do
  use EmbedChat.Web, :controller
  alias EmbedChat.User
  alias EmbedChat.Room
  alias EmbedChat.UserRoom

  # plug :authenticate when action in [:index, :show]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        add_room user
        conn
        |> EmbedChat.Auth.login(user)
        |> put_flash(:info, "Your account was created!")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp add_room(user) do
    case Repo.insert(%Room{uuid: Ecto.UUID.generate()}) do
      {:ok, room} ->
        Repo.insert(%UserRoom{user_id: user.id, room_id: room.id})
    end
  end
end
