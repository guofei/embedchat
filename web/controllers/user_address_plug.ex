defmodule EmbedChat.UserAddressPlug do
  import Plug.Conn
  alias EmbedChat.Address

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user = Guardian.Plug.current_resource(conn)
    if user do
      # TODO change to current user project's room
      room = Ecto.assoc(user, :rooms) |> EmbedChat.Room.first |> repo.one
      if room do
        address = create_or_get_address(user, room, repo)
        assign(conn, :user_address, address.uuid)
      else
        assign(conn, :user_address, nil)
      end
    else
      assign(conn, :user_address, nil)
    end
  end

  defp create_or_get_address(user, room, repo) do
    if address = repo.one(Address.latest_for_room_master(Address, user.id, room.id)) do
      address
    else
      changeset = Ecto.build_assoc(user, :addresses, uuid: Ecto.UUID.generate(), room_id: room.id)
      case repo.insert(changeset) do
        {:ok, address} ->
          address
      end
    end
  end
end
