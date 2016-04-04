defmodule EmbedChat.RoomChannelTest do
  use EmbedChat.ChannelCase
  alias EmbedChat.RoomChannel

  setup config do
    {room, owner} = create_room
    cond do
      config[:master] && config[:visitor] ->
        {:ok, _, master} = join_room(owner.id, uuid(), room.uuid)
        {:ok, _, visitor} = join_room(uuid(), room.uuid)
        {:ok, master: master, visitor: visitor}
      config[:master] ->
        {:ok, _, master} = join_room(owner.id, uuid(), room.uuid)
        {:ok, socket: master}
      true ->
        {:ok, _, visitor} = join_room(uuid(), room.uuid)
        {:ok, socket: visitor}
    end
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  @tag master: true, visitor: true
  test "visitor send accesslog to master", %{visitor: v} do
    info = %{uid: v.assigns.distinct_id, info: %{userAgent: "IE", href: "abc.com"}}
    push v, "user_info", info
    assert_broadcast "user_info", info
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
    assert_reply ref, :ok, %{messages: [m1, m2]}
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
    assert_reply ref, :ok, %{messages: [m1, m2]}
  end

  #test "get history messages by visitor with invalid data", %{master: m, visitor: v} do
  #end

  @tag master: true, visitor: true
  test "get contact list by master", %{master: m, visitor: _v} do
    ref = push m, "contact_list", %{}
    assert_reply ref, :ok, %{users: [u1, u2]}
  end

  test "get contact list by visitor", %{socket: socket} do
    ref = push socket, "contact_list", %{}
    assert_reply ref, :error
  end

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
    assert_broadcast "new_message", message
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
    {room, owner}
  end

  defp join_room(distinct_id, room_uuid) do
    info = %{"userAgent" => "IE", "href" => "http://a.com"}
    socket = socket(distinct_id, %{distinct_id: distinct_id, info: info})
    socket
    |> subscribe_and_join(RoomChannel, "rooms:#{room_uuid}")
  end

  defp join_room(user_id, distinct_id, room_uuid) do
    info = %{"userAgent" => "IE", "href" => "http://a.com"}
    socket = socket(distinct_id, %{distinct_id: distinct_id, info: info})
    socket
    |> Phoenix.Socket.assign(:user_id, user_id)
    |> subscribe_and_join(RoomChannel, "rooms:#{room_uuid}")
  end
end
