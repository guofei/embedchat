defmodule EmbedChat.AdminPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns[:admin] do
      conn
    else
      admin = Guardian.Plug.current_resource(conn, :admin)
      conn |> assign(:admin, admin)
    end
  end
end
