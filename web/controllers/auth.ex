defmodule EmbedChat.Auth do
  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
  end

  def logout(conn) do
    conn
    |> Guardian.Plug.sign_out
  end

  import Comeonin.Bcrypt, only: [checkpw: 2]

  def login_by_email_and_pass(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(EmbedChat.User, email: email)

    cond do
      user && checkpw(given_pass, user.crypted_password) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
  end

  # for test
  import Plug.Conn
  import Phoenix.Controller
  alias EmbedChat.Router.Helpers
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
