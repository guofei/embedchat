defmodule EmbedChatWeb.Admin.SessionController do
  use EmbedChatWeb, :controller

  plug Guardian.Plug.EnsureAuthenticated, [key: :admin] when action in [:delete, :impersonate, :stop_impersonating]

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" =>
                                     pass}}) do
    case EmbedChatWeb.Auth.admin_login_by_email_and_pass(conn, email, pass, repo:
          Repo) do
      {:ok, conn} ->
        conn
        |> redirect(to: admin_user_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out(:admin)
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: page_path(conn, :index))
  end

  def impersonate(conn, params) do
    user = Repo.get(EmbedChat.User, params["user_id"])
    conn
    |> Guardian.Plug.sign_out(:default)
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end

  def stop_impersonating(conn, _) do
    conn
    |> Guardian.Plug.sign_out(:default)
    |> redirect(to: admin_user_path(conn, :index))
  end
end
