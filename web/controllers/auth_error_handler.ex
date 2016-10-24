defmodule EmbedChat.AuthErrorHandler do
  import Plug.Conn
  import Phoenix.Controller
  alias EmbedChat.Router.Helpers

  # handle the case where no authenticated user
  # was found
  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must be logged in to access that page")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end
end
