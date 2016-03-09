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
    get_or_create_admin_adress(socket)
    broadcast! socket, "user_join", %{distinct_id: socket.assigns.distinct_id}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
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
    case get_or_create_from_address(socket) do
      {:ok, address} ->
        income = admin_address(socket.assigns.room_id)
        changeset =
          address
        |> build_assoc(:sent_messages, %{incoming_id: income.id})
        |> EmbedChat.Message.changeset(%{
              message_type: "message",
              body: payload["body"]})
        Repo.insert(changeset)
        param = %{
          body: payload["body"],
          name: socket.assigns.distinct_id
        }
        broadcast! socket, "new_message", param
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, changeset.errors}, socket}
    end
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    # TODO
    push socket, event, payload
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    distinct_id = socket.assigns.distinct_id
    broadcast! socket, "user_left", %{distinct_id: distinct_id}
    offline(socket.assigns.room_id, distinct_id)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp online_users(room_id) do
    {:ok, bucket} = bucket(room_id)
    EmbedChat.Room.Bucket.get(bucket)
  end

  defp online(room_id, distinct_id) do
    reg = EmbedChat.Room.Registry
    EmbedChat.Room.Registry.create(reg, "rooms:#{room_id}")
    {:ok, bucket} = EmbedChat.Room.Registry.lookup(reg, "rooms:#{room_id}")
    EmbedChat.Room.Bucket.add(bucket, distinct_id)
  end

  defp offline(room_id, distinct_id) do
    {:ok, bucket} = bucket(room_id)
    EmbedChat.Room.Bucket.delete(bucket, distinct_id)
  end

  defp bucket(room_id) do
    reg = EmbedChat.Room.Registry
    {:ok, bucket} = EmbedChat.Room.Registry.lookup(reg, "rooms:#{room_id}")
  end

  defp admin(room_id) do
    room =
      EmbedChat.Repo.get(EmbedChat.Room, room_id)
    |> EmbedChat.Repo.preload(:user)

    room.user
  end

  defp admin_address(room_id) do
    user = EmbedChat.Repo.preload(admin(room_id), :addresses)
    List.first(user.addresses)
  end

  defp get_or_create_admin_adress(socket) do
    cond do
      socket.assigns[:user_id] ->
        get_or_create_from_address(socket)
      true ->
        {:error, nil}
    end
  end

  defp get_or_create_from_address(socket) do
    room = EmbedChat.Repo.get(EmbedChat.Room, socket.assigns.room_id)
    distinct_id = socket.assigns.distinct_id

    from_address =
      cond do
      address = EmbedChat.Repo.get_by(EmbedChat.Address, uuid: distinct_id) ->
        {:ok, address}
      true ->
        changeset =
          room
        |> build_assoc(:addresses, user_id: socket.assigns[:user_id])
        |> EmbedChat.Address.changeset(%{uuid: distinct_id})
        EmbedChat.Repo.insert(changeset)
    end
  end
end
