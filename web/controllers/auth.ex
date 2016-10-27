defmodule EmbedChat.Auth do
  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
  end

  def admin_login(conn, user) do
    if EmbedChat.User.admin?(user) do
      conn
      |> Guardian.Plug.sign_in(user, :access, key: :admin)
    else
      conn
    end
  end

  def logout(conn) do
    conn
    |> Guardian.Plug.sign_out(:default)
  end

  import Comeonin.Bcrypt, only: [checkpw: 2]

  def login_by_email_and_pass(conn, email, given_pass, opts) do
    with {:ok, user} <- get_user_and_checkpw(conn, email, given_pass, opts),
      do: {:ok, login(conn, user)}
  end

  def admin_login_by_email_and_pass(conn, email, given_pass, opts) do
    with {:ok, user} <- get_user_and_checkpw(conn, email, given_pass, opts),
      do: {:ok, admin_login(conn, user)}
  end

  defp get_user_and_checkpw(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(EmbedChat.User, email: email)

    cond do
      user && checkpw(given_pass, user.crypted_password) ->
        {:ok, user}
      user ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
  end
end
