defmodule EmbedChat.RoomChannel do
  use EmbedChat.Web, :channel

  def join("rooms:" <> room_id, payload, socket) do
    if authorized?(payload) do
      reg = EmbedChat.Room.Registry
      EmbedChat.Room.Registry.create(reg, "rooms:#{room_id}")
      {:ok, bucket} = EmbedChat.Room.Registry.lookup(reg, "rooms:#{room_id}")
      EmbedChat.Room.Bucket.add(bucket, socket.assigns.distinct_id)
      {:ok, assign(socket, :room_id, room_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("contact_list", payload, socket) do
    if socket.assigns[:user_id] do
      room_id = socket.assigns.room_id
      reg = EmbedChat.Room.Registry
      {:ok, bucket} = EmbedChat.Room.Registry.lookup(reg, "rooms:#{room_id}")
      {:reply, {:ok, %{online: EmbedChat.Room.Bucket.get(bucket)}}, socket}
    else
      {:reply, {:ok, payload}, socket}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (rooms:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("new_message", payload, socket) do
    room = EmbedChat.Repo.get(EmbedChat.Room, socket.assigns.room_id)
    distinct_id = socket.assigns.distinct_id
    case get_or_create_from_address(socket, room, distinct_id) do
      {:ok, address} ->
        # changeset =
        #   address
        # |> build_assoc(:sent_messages)
        # |> EmbedChat.Message.changeset(%{
        #       type: "message",
        #       body: payload["body"]})
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

#   def handle_out("contact_list", %{user_id: user_id}, socket) do
#     broadcast! socket, "user_join", %{to: user_id, distinct_id: socket.assigns.distinct_id}
#     {:noreply, socket}
#   end

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
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp get_or_create_from_address(socket, room, distinct_id) do
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
