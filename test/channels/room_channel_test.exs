defmodule EmbedChat.RoomChannelTest do
  use EmbedChat.ChannelCase
  alias EmbedChat.RoomChannel

  setup config do
    {room, owner} = create_room()
    cond do
      config[:master] && config[:visitor] ->
        {:ok, _, master} = join_room(owner, uuid(), room.uuid)
        {:ok, _, visitor} = join_room(uuid(), room.uuid)
        {:ok, master: master, visitor: visitor}
      config[:master] ->
        {:ok, _, master} = join_room(owner, uuid(), room.uuid)
        {:ok, socket: master}
      true ->
        {:ok, _, visitor} = join_room(uuid(), room.uuid)
        {:ok, socket: visitor}
    end
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  @tag master: true, visitor: true
  test "get history messages by master", %{master: m, visitor: v} do
    to_master = %{"body" => "some content", "to_id" => m.assigns.distinct_id}
    to_vistor = %{"body" => "some content", "to_id" => v.assigns.distinct_id}
    ref = push m, "new_message", to_vistor
    assert_reply ref, :ok
    ref = push v, "new_message", to_master
    assert_reply ref, :ok
    ref = push m, "messages", %{uid: v.assigns.distinct_id}
    assert_reply ref, :ok, %{messages: [_, _]}
  end

  @tag master: true, visitor: true
  test "get history messages by visitor", %{master: m, visitor: v} do
    to_master = %{"body" => "some content", "to_id" => m.assigns.distinct_id}
    to_vistor = %{"body" => "some content", "to_id" => v.assigns.distinct_id}
    ref = push v, "new_message", to_master
    assert_reply ref, :ok
    ref = push m, "new_message", to_vistor
    assert_reply ref, :ok
    ref = push v, "messages", %{uid: v.assigns.distinct_id}
    assert_reply ref, :ok, %{messages: [_, _]}
  end

  #test "get history messages by visitor with invalid data", %{master: m, visitor: v} do
  #end

  @tag master: true, visitor: true
  test "get contact list by master", %{master: m, visitor: _v} do
    ref = push m, "contact_list", %{}
    assert_reply ref, :ok, %{online_users: %{}, offline_users: %{}}
  end

  test "get admin list by visitor", %{socket: socket} do
    ref = push socket, "contact_list", %{}
    assert_reply ref, :ok, %{admins: %{}}
  end

  # TODO user_join, user_left, admin_join, admin_left

  @tag master: false, visitor: true
  test "visitor send message to offline master", %{socket: socket} do
    msg = %{"body" => "some content", "to_id" => uuid()}
    ref = push socket, "new_message", msg
    assert_reply ref, :ok
  end

  @tag master: true, visitor: true
  test "visitor send message to online master", %{master: m, visitor: v} do
    message = %{"body" => "some content", "to_id" => m.assigns.distinct_id}
    push v, "new_message", message
    assert_broadcast "new_message", %{body: "some content",
                                      to_id: _,
                                      from_id: _,
                                      from_name: _,
                                      id: _,
                                      inserted_at: _}
  end

  @tag master: true
  test "master send message to visitor", %{socket: s} do
    to_visitor = %{"body" => "some content", "to_id" => s.assigns.distinct_id}
    push s, "new_message", to_visitor
    assert_broadcast "new_message", %{}
  end

  defp create_room do
    owner = insert_user(username: "sneaky")
    room = insert_room(owner, %{})
    insert_address(owner, room)
    {room, owner}
  end

  defp join_room(distinct_id, room_uuid) do
    info = %{"userAgent" => "IE", "href" => "http://a.com"}
    socket = socket(distinct_id, %{distinct_id: distinct_id, info: info})
    socket
    |> subscribe_and_join(RoomChannel, "rooms:#{room_uuid}")
  end

  defp join_room(user, distinct_id, room_uuid) do
    info = %{"userAgent" => "IE", "href" => "http://a.com"}
    socket = socket(distinct_id, %{distinct_id: distinct_id, info: info})
    socket
    |> Phoenix.Socket.assign(:current_user, user)
    |> subscribe_and_join(RoomChannel, "rooms:#{room_uuid}")
  end
end
