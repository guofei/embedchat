defmodule EmbedChat.UserController do
  use EmbedChat.Web, :controller
  alias EmbedChat.User
  alias EmbedChat.UserRoom
  alias EmbedChat.Room

  plug :authenticate_user when action in [:index, :show, :edit, :update]

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
        |> redirect(to: page_path(conn, :welcome))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def index(conn, _params) do
    user = conn.assigns.current_user
    render(conn, "show.html", user: user)
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => _id}) do
    user = conn.assigns.current_user
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "user" => user_params}) do
    user = conn.assigns.current_user
    changeset = User.registration_changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  defp create_room(user) do
    case Repo.insert(%Room{uuid: Ecto.UUID.generate()}) do
      {:ok, room} ->
        Repo.insert(%UserRoom{user_id: user.id, room_id: room.id})
    end
  end
end
