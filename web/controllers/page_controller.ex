defmodule EmbedChat.PageController do
  use EmbedChat.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      room = Repo.one(user_rooms conn)
      render conn, "index.html", room: room
    else
      render conn, "index.html"
    end
  end

  def price(conn, _params) do
    render conn, "price.html"
  end
end
