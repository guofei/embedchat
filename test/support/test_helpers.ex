defmodule EmbedChat.TestHelpers do
  alias EmbedChat.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
          email:    "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@email.com",
          name:     "name",
          password: "supersecret",
                     }, Enum.into(attrs, %{}))

    %EmbedChat.User{}
    |> EmbedChat.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_room(user, _attrs \\ %{}) do
    {_, project} = Repo.insert(%EmbedChat.Project{})
    Repo.insert(%EmbedChat.UserProject{user_id: user.id, project_id: project.id})
    {_, room} = Repo.insert(%EmbedChat.Room{uuid: uuid(), project_id: project.id})
    room
  end

  def insert_room() do
    user = insert_user()
    {_, project} = Repo.insert(%EmbedChat.Project{})
    Repo.insert(%EmbedChat.UserProject{user_id: user.id, project_id: project.id})
    {_, room} = Repo.insert(%EmbedChat.Room{uuid: uuid(), project_id: project.id})
    room
  end

  def insert_visitor() do
    {_, visitor} = Repo.insert(%EmbedChat.Visitor{email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@email.com"})
    visitor
  end

  def insert_address(%EmbedChat.User{} = user, room) do
    {_, address} = Repo.insert(%EmbedChat.Address{user_id: user.id, uuid: uuid(), room_id: room.id})
    address
  end

  def insert_address(%EmbedChat.Visitor{} = visitor, room) do
    {_, address} = Repo.insert(%EmbedChat.Address{visitor_id: visitor.id, uuid: uuid(), room_id: room.id})
    address
  end

  def insert_address() do
    user = insert_user()
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
