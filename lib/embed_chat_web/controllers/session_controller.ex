defmodule EmbedChatWeb.SessionController do
  use EmbedChatWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" =>
                                     pass}}) do
    case EmbedChatWeb.Auth.login_by_email_and_pass(conn, email, pass, repo:
          Repo) do
      {:ok, conn} ->
        conn
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> EmbedChatWeb.Auth.logout()
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: page_path(conn, :index))
  end
end
