defmodule EmbedChatWeb.UserPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      user = Guardian.Plug.current_resource(conn)
      conn |> assign(:current_user, user)
    end
  end
end
