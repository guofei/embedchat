defmodule EmbedChat.Admin.UserController do
  use EmbedChat.Web, :controller
  alias EmbedChat.User
  alias EmbedChat.UserRoom
  alias EmbedChat.Room

  plug Guardian.Plug.EnsureAuthenticated, [key: :admin]

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
        |> redirect(to: admin_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def index(conn, params) do
    users = EmbedChat.User |> EmbedChat.User.sorted |> Repo.paginate(params)
    render(conn, "index.html", users: users)
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

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: admin_user_path(conn, :show, user))
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
