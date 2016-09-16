defmodule EmbedChat.UserController do
  use EmbedChat.Web, :controller
  alias EmbedChat.User
  alias EmbedChat.UserRoom
  alias EmbedChat.Room

  plug :authenticate_user when action in [:show]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        create_room user
        conn
        |> EmbedChat.Auth.login(user)
        |> put_flash(:info, "Your account was created!")
        |> redirect(to: room_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  defp create_room(user) do
    case Repo.insert(%Room{uuid: Ecto.UUID.generate()}) do
      {:ok, room} ->
        Repo.insert(%UserRoom{user_id: user.id, room_id: room.id})
    end
  end
end
