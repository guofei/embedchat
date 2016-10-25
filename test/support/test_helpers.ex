defmodule EmbedChat.TestHelpers do
  alias EmbedChat.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
          email:    "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@email.com",
          name:     "name",
          password: "supersecret",
                     }, attrs)

    %EmbedChat.User{}
    |> EmbedChat.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_room(user, _attrs \\ %{}) do
    {_, room} = Repo.insert(%EmbedChat.Room{uuid: uuid()})
    Repo.insert(%EmbedChat.UserRoom{user_id: user.id, room_id: room.id})
    room
  end

  def insert_room() do
    user = insert_user
    {_, room} = Repo.insert(%EmbedChat.Room{uuid: uuid()})
    Repo.insert(%EmbedChat.UserRoom{user_id: user.id, room_id: room.id})
    room
  end

  def insert_address(user, room) do
    {_, address} = Repo.insert(%EmbedChat.Address{user_id: user.id, uuid: uuid(), room_id: room.id})
    address
  end

  def insert_address() do
    user = insert_user
    room = insert_room(user)
    {_, address} = Repo.insert(%EmbedChat.Address{uuid: uuid(), room_id: room.id})
    address
  end

  def uuid do
    Ecto.UUID.generate()
  end

  use Phoenix.ConnTest
  @endpoint EmbedChat.Endpoint

  def guardian_login(conn, user, token \\ :token, opts \\ []) do
    conn
    |> bypass_through(EmbedChat.Router, [:browser])
    |> get("/")
    |> Guardian.Plug.sign_in(user, token, opts)
    |> send_resp(200, "Flush the session yo")
    |> recycle()
  end
end
