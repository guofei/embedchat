defmodule EmbedChat.UserTokenPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns[:user_token] do
      conn
    else
      jwt = Guardian.Plug.current_token(conn)
      conn |> assign(:user_token, jwt)
    end
  end
end
