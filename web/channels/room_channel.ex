defmodule EmbedChat.RoomChannel do
  use EmbedChat.Web, :channel
  alias EmbedChat.ChannelWatcher
  alias EmbedChat.Message
  alias EmbedChat.Room
  alias EmbedChat.RoomChannelSF
  alias EmbedChat.User

  def join("rooms:" <> room_uuid, _payload, socket) do
    cond do
      room = Repo.get_by(Room, uuid: room_uuid) ->
        if authorized?(socket, room) do
          send(self, :after_join)
          ChannelWatcher.monitor(
            :rooms,
            self(),
            {__MODULE__, :leave, [
                room.id,
                room.uuid,
                socket.assigns[:user_id],
                socket.assigns.distinct_id]
            })
          new_socket =
            socket
            |> assign(:room_id, room.id)
            |> assign(:room_uuid, room.uuid)
          {:ok, new_socket}
        else
          {:error, %{reason: "unauthorized"}}
        end
      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    if socket.assigns[:user_id] do
      user = Repo.get!(User, socket.assigns.user_id)
      RoomChannelSF.admin_online(socket.assigns.room_id, socket.assigns.distinct_id, user)
      RoomChannelSF.create_admin_address(socket)
      broadcast! socket, "admin_join", %{uid: socket.assigns.distinct_id}
    else
      RoomChannelSF.visitor_online(socket.assigns.room_id, socket.assigns.distinct_id, socket.assigns[:info])
      broadcast! socket, "user_join", %{uid: socket.assigns.distinct_id}
    end
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("user_info", payload, socket) do
    room_id = socket.assigns.room_id
    distid = socket.assigns.distinct_id
    if !socket.assigns[:user_id] do
      messages = RoomChannelSF.auto_messages(room_id, payload)
      Enum.each(messages, fn (msg) ->
        msg = %{"to_id" => distid, "body" => msg.message}
        if {:ok, resp} = RoomChannelSF.new_message_master_to_visitor(msg, room_id) do
          push socket, "new_message", resp
        end
      end)
      RoomChannelSF.visitor_update(socket.assigns.room_id, socket.assigns.distinct_id, payload)
      broadcast! socket, "user_info", %{uid: socket.assigns.distinct_id, info: payload}
    end
    {:noreply, socket}
  end

  def handle_in("messages", payload, socket) do
    room_id = socket.assigns.room_id
    uuid = RoomChannelSF.messages_owner(payload, socket)

    limit = 50
    cond do
      address = RoomChannelSF.get_address(uuid) ->
        query = from m in Message,
          order_by: [desc: :inserted_at],
          where: m.room_id == ^(room_id) and (m.from_id == ^(address.id) or m.to_id == ^(address.id)),
          limit: ^limit,
          preload: [:from, :to, :from_user]
        messages = Repo.all(query)
        resp = %{uid: uuid, messages: Phoenix.View.render_many(
                    messages,
                    EmbedChat.MessageView,
                    "message.json"
                  )}
        {:reply, {:ok, resp}, socket}
      true ->
        {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_in("contact_list", _payload, socket) do
    if socket.assigns[:user_id] do
      {:reply, {:ok, %{users: RoomChannelSF.online_visitors(socket.assigns.room_id)}}, socket}
    else
      {:reply, {:ok, %{admins: RoomChannelSF.online_admins(socket.assigns.room_id)}}, socket}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (rooms:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("new_message", payload, socket) do
    case RoomChannelSF.new_message(payload, socket) do
      {:ok, resp} ->
        broadcast! socket, "new_message", resp
        {:reply, {:ok, resp}, socket}
      {:error, changeset} ->
        {:reply, {:error, Enum.into(changeset.errors, %{})}, socket}
    end
  end

  intercept ["new_message", "user_info"]

  def handle_out("user_info", payload, socket) do
    if socket.assigns[:user_id] do
      push socket, "user_info", payload
    end
    {:noreply, socket}
  end

  def handle_out("new_message", payload, socket) do
    cond do
      payload[:to_id] == socket.assigns.distinct_id ->
        push socket, "new_message", payload
        {:noreply, socket}
      payload[:from_id] == socket.assigns.distinct_id ->
        push socket, "new_message", payload
        {:noreply, socket}
      true ->
        {:noreply, socket}
    end
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    EmbedChat.ChannelWatcher.demonitor(:rooms, self())

    distinct_id = socket.assigns.distinct_id
    leave(socket.assigns.room_id, socket.assigns.room_uuid, socket.assigns[:user_id], distinct_id)

    {:noreply, socket}
  end

  def leave(room_id, room_uuid, user_id, distinct_id) when is_nil(user_id) do
    EmbedChat.Endpoint.broadcast! "rooms:#{room_uuid}", "user_left", %{uid: distinct_id}
    RoomChannelSF.visitor_offline(room_id, distinct_id)
  end

  def leave(room_id, room_uuid, _user_id, distinct_id) do
    EmbedChat.Endpoint.broadcast! "rooms:#{room_uuid}", "admin_left", %{uid: distinct_id}
    RoomChannelSF.admin_offline(room_id, distinct_id)
  end

  # Add authorization logic here as required.
  defp authorized?(socket, room) do
    cond do
      user_id = socket.assigns[:user_id] ->
        room = Repo.preload room, :users
        users = room.users
        user = Repo.get!(User, user_id)
        Enum.any?(users, &(&1.id == user.id))
      true ->
        true
    end
  end
end
