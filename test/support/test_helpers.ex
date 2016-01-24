defmodule EmbedChat.TestHelpers do
  alias EmbedChat.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
          email:    "user#{Base.encode16(:crypto.rand_bytes(8))}@email.com",
          password: "supersecret",
                     }, attrs)

    %EmbedChat.User{}
    |> EmbedChat.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_room(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:rooms)
    |> EmbedChat.Room.changeset(attrs)
    |> Repo.insert!()
  end
end
