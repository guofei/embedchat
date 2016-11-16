defmodule EmbedChat.AddressController do
  use EmbedChat.Web, :controller

  alias EmbedChat.Address
  plug Guardian.Plug.EnsureAuthenticated, [handler: EmbedChat.AuthErrorHandler]

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    addresses = Repo.paginate(Address, params)
    render(conn, "index.html", addresses: addresses)
  end

  def show(conn, %{"id" => id}) do
    address = Repo.get!(Address, id)
    render(conn, "show.html", address: address)
  end
end
