defmodule EmbedChat.TestHelpers do
  alias EmbedChat.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
          email:    "user#{Base.encode16(:crypto.rand_bytes(8))}@email.com",
          name:     "name",
          password: "supersecret",
                     }, attrs)

    %EmbedChat.User{}
    |> EmbedChat.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_room(user, attrs \\ %{}) do
    {_, room} = Repo.insert(%EmbedChat.Room{uuid: Ecto.UUID.generate()})
    Repo.insert(%EmbedChat.UserRoom{user_id: user.id, room_id: room.id})
    room
  end
end
