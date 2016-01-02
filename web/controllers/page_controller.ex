defmodule EmbedChat.PageController do
  use EmbedChat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
