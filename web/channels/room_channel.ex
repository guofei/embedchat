defmodule EmbedChat.RoomChannel do
  use EmbedChat.Web, :channel

  def join("rooms:" <> room_id, payload, socket) do
    if authorized?(payload) do
      send(self, :after_join)
      {:ok, assign(socket, :room_id, room_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    online(socket.assigns.room_id, socket.assigns.distinct_id)
    if socket.assigns[:user_id] do
      admin_online(socket.assigns.room_id, socket.assigns.distinct_id)
      create_admin_address(socket)
    end
    broadcast! socket, "user_join", %{uid: socket.assigns.distinct_id}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("messages", payload, socket) do
    uuid = socket.assigns.distinct_id
    room_id = socket.assigns.room_id
    address = get_address(room_id, uuid, nil)
    cond do
      query = from m in EmbedChat.Message, where: m.from_id == ^(address.id) or m.to_id == ^(address.id) ->
        cond do
          messages = EmbedChat.Repo.all(query) ->
            {:reply, {:ok, %{messages: messages}}, socket}
          true ->
            {:reply, {:error, %{reason: "0 messages"}}, socket}
        end
      true ->
        {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_in("contact_list", payload, socket) do
    if socket.assigns[:user_id] do
      {:reply, {:ok, %{users: online_users(socket.assigns.room_id)}}, socket}
    else
      {:reply, {:error, %{reason: "unauthorized"}}, socket}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (rooms:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("new_message", payload, socket) do
    case sender(socket) do
      {:ok, sender} ->
        case receiver(socket, payload["to"]) do
          {:ok, receiver} ->
            case create_message(sender, receiver, payload["body"]) do
              {:ok, msg} ->
                broadcast! socket, "new_message", msg
                {:noreply, socket}
              {:error, changeset} ->
                {:reply, {:error, changeset.errors}, socket}
            end
          {:error, _ } ->
            {:reply, {:error, %{reason: "unknown receiver"}}, socket}
        end
      {:error, changeset} ->
        {:reply, {:error, changeset.errors}, socket}
    end
  end

  intercept ["new_message"]

  def handle_out("new_message", payload, socket) do
    cond do
      payload[:to] == socket.assigns.distinct_id ->
        push socket, "new_message", payload
        {:noreply, socket}
      payload[:from] == socket.assigns.distinct_id ->
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

  def terminate(reason, socket) do
    distinct_id = socket.assigns.distinct_id
    broadcast! socket, "user_left", %{uid: distinct_id}
    offline(socket.assigns.room_id, distinct_id)
    if socket.assigns[:user_id] do
      admin_offline(socket.assigns.room_id, distinct_id)
    end
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp online_users(room_id) do
    {:ok, bucket} = user_bucket(room_id)
    EmbedChat.Room.Bucket.get(bucket)
  end

  defp online(room_id, distinct_id) do
    {:ok, bucket} = user_bucket(room_id)
    EmbedChat.Room.Bucket.add(bucket, distinct_id)
  end

  defp offline(room_id, distinct_id) do
    {:ok, bucket} = user_bucket(room_id)
    EmbedChat.Room.Bucket.delete(bucket, distinct_id)
  end

  defp online_admins(room_id) do
    {:ok, bucket} = admin_bucket(room_id)
    EmbedChat.Room.Bucket.get(bucket)
  end

  defp admin_online(room_id, distinct_id) do
    {:ok, bucket} = admin_bucket(room_id)
    EmbedChat.Room.Bucket.add(bucket, distinct_id)
  end

  defp admin_offline(room_id, distinct_id) do
    {:ok, bucket} = admin_bucket(room_id)
    EmbedChat.Room.Bucket.delete(bucket, distinct_id)
  end

  defp user_bucket(room_id) do
    bucket(room_id)
  end

  defp admin_bucket(room_id) do
    bucket("admin:#{room_id}")
  end

  defp bucket(id) do
    reg = EmbedChat.Room.Registry
    case EmbedChat.Room.Registry.lookup(reg, "rooms:#{id}") do
      {:ok, bucket} ->
        {:ok, bucket}
      :error ->
        EmbedChat.Room.Registry.create(reg, "rooms:#{id}")
        EmbedChat.Room.Registry.lookup(reg, "rooms:#{id}")
    end
  end

  defp receiver(socket, to) do
    cond do
      socket.assigns[:user_id] ->
        get_or_create_address(socket.assigns.room_id, to, nil)
      true ->
        admin_address(socket.assigns.room_id)
    end
  end

  defp sender(socket) do
    get_or_create_address(socket.assigns.room_id,
                          socket.assigns.distinct_id,
                          socket.assigns[:user_id])
  end

  defp admin_address(room_id) do
    # TODO multi users
    admin = List.first online_admins(room_id)
    cond do
      address = get_address(room_id, admin, nil) ->
        {:ok, address}
      true ->
        {:error, %{reason: "unknown address"}}
    end
  end

  defp create_message(sender, receiver, text) do
    changeset =
      sender
    |> build_assoc(:outgoing_messages, %{from_id: receiver.id})
    |> EmbedChat.Message.changeset(%{
          message_type: "message",
          body: text})
    Repo.insert(changeset)
  end

  defp create_admin_address(socket) do
    if socket.assigns[:user_id] do
      sender(socket)
    end
  end

  defp get_or_create_address(room_id, distinct_id, user_id) do
    cond do
      address = get_address(room_id, distinct_id, user_id) ->
        {:ok, address}
    true ->
      create_address(room_id, distinct_id, user_id)
    end
  end

  defp get_address(room_id, distinct_id, user_id) when is_nil(distinct_id) do
    nil
  end

  defp get_address(room_id, distinct_id, user_id) when is_nil(user_id) do
    EmbedChat.Repo.get_by(EmbedChat.Address, uuid: distinct_id, room_id: room_id)
  end

  defp get_address(room_id, distinct_id, user_id) do
    EmbedChat.Repo.get_by(EmbedChat.Address, uuid: distinct_id, room_id: room_id, user_id: user_id)
  end

  defp create_address(room_id, distinct_id, user_id) do
    room = EmbedChat.Repo.get(EmbedChat.Room, room_id)
    changeset =
      room
    |> build_assoc(:addresses, user_id: user_id)
    |> EmbedChat.Address.changeset(%{uuid: distinct_id})
    EmbedChat.Repo.insert(changeset)
  end
end
