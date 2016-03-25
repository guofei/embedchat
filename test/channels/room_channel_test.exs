defmodule EmbedChat.RoomChannelTest do
  use EmbedChat.ChannelCase
  alias EmbedChat.RoomChannel

  @from "1ecf9637-bb8e-413c-bec5-8c5955d40406"
  @to "804f2df3-afe4-4018-83e2-c7129b3cbf08"
  @valid_message %{"body" => "some content", "to_id" => @to}

  setup do
    owner = insert_user(username: "sneaky")
    room = insert_room(owner, %{})
    socket = socket(@from, %{distinct_id: @from})

    {:ok, socket: socket, room: room, owner: owner}
  end

  setup %{socket: socket, room: room, owner: owner} = config do
    if config[:master] do
      {:ok, _, socket} =
        socket
      |> Phoenix.Socket.assign(:user_id, owner.id)
      |> subscribe_and_join(RoomChannel, "rooms:#{room.id}")
      {:ok, socket: socket}
    else
      {:ok, _, socket} =
        socket
      |> subscribe_and_join(RoomChannel, "rooms:#{room.id}")
      {:ok, socket: socket}
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

  test "visitor send message to offline master", %{socket: socket} do
    ref = push socket, "new_message", @valid_message
    assert_reply ref, :error
  end

  @tag master: true
  test "visitor send message to online master", %{socket: socket} do
    {:ok, _, visitor} = socket(@to, %{distinct_id: @to})
    |> subscribe_and_join(RoomChannel, "rooms:#{socket.assigns.room_id}")
    message = %{"body" => "some content", "to_id" => @from}
    push visitor, "new_message", message
    assert_broadcast "new_message", message
  end

  @tag master: true
  test "master send message to visitor", %{socket: socket} do
    push socket, "new_message", @valid_message
    assert_broadcast "new_message", %{}
  end
end
