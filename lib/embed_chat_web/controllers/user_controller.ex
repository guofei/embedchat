defmodule EmbedChatWeb.UserController do
  use EmbedChatWeb, :controller
  alias EmbedChat.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: EmbedChatWeb.AuthErrorHandler] when action in [:index, :show, :edit, :update]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        create_project user
        conn
        |> EmbedChatWeb.Auth.login(user)
        |> redirect(to: page_path(conn, :welcome))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def index(conn, _params) do
    user = conn.assigns.current_user
    render(conn, "show.html", user: user)
  end

  def show(conn, %{"id" => _id}) do
    user = conn.assigns.current_user
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
end
