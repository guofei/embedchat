defmodule EmbedChat.PageController do
  use EmbedChat.Web, :controller
  alias EmbedChat.Attempt

  plug Guardian.Plug.EnsureAuthenticated, [handler: EmbedChat.AuthErrorHandler] when action in [:welcome]

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    if user do
      room = Repo.one(user_rooms conn)
      render conn, "index.html", room: room
    else
      changeset = Attempt.changeset(%Attempt{})
      render conn, "index.html", attempt: changeset
    end
  end

  def price(conn, _params) do
    render conn, "price.html"
  end

  def welcome(conn, _params) do
    render conn, "welcome.html"
  end
end
