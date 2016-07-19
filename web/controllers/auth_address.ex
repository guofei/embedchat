defmodule EmbedChat.AuthAddress do
  import Plug.Conn
  alias EmbedChat.Address
  alias EmbedChat.Repo

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    if user = conn.assigns[:current_user] do
      room = EmbedChat.Room |> EmbedChat.Room.first |> repo.one
      if room do
        address = create_or_get_address(user, room)
        assign(conn, :user_address, address.uuid)
      else
        assign(conn, :user_address, nil)
      end
    else
      assign(conn, :user_address, nil)
    end
  end

  defp create_or_get_address(user, room) do
    if address = Repo.one(Address.latest_for_user_room(Address, user.id, room.id)) do
      address
    else
      changeset = Ecto.build_assoc(user, :addresses, uuid: Ecto.UUID.generate(), room_id: room.id)
      case Repo.insert(changeset) do
        {:ok, address} ->
          address
      end
    end
  end
end
