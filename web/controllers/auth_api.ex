defmodule EmbedChat.AuthAPI do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    if conn.assigns[:current_user] do
      conn
    else
      conn |> validate_token(conn.params["token"], repo)
    end
  end

  def validate_token(conn, token, _repo) when is_nil(token) do
    conn |> send_resp(401, "Missing valid API token") |> halt
  end

  def validate_token(conn, token, repo) do
    case assign_user(conn, token, repo) do
      :invalid_token ->
        conn |> send_resp(401, "Invalid API token") |> halt
      {:authenticated, user} ->
        conn
        |> assign(:api_status, {200, "ok"})
        |> assign(:current_user, user)
    end
  end

  @max_age 2 * 7 * 24 * 60 * 60

  def assign_user(conn, token, repo) do
    case Phoenix.Token.verify(conn, "user", token, max_age: @max_age) do
      {:ok, user_id} ->
        user =
          EmbedChat.User
          |> repo.get!(user_id)
        {:authenticated, user}
      {:error, _reason} ->
        :invalid_token
    end
  end
end
