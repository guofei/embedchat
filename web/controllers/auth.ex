defmodule EmbedChat.Auth do
  import Plug.Conn
  alias EmbedChat.Address
  alias EmbedChat.Repo

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && repo.get(EmbedChat.User, user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)
    address = create_or_get_address(user)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
    |> assign(:user_address, address.uuid)
  end

  defp create_or_get_address(user) do
    cond do
      address = Repo.one(Address.latest_for_user(Address, user.id)) ->
        address
      true ->
        changeset = Ecto.build_assoc(user, :addresses, uuid: Ecto.UUID.generate())
        case Repo.insert(changeset) do
          {:ok, address} ->
            address
        end
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
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
