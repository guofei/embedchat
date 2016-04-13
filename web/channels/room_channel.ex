defmodule EmbedChat.RoomChannel do
  use EmbedChat.Web, :channel
  alias EmbedChat.Room.Bucket
  alias EmbedChat.Room.Registry
  alias EmbedChat.Message
  alias EmbedChat.User
  alias EmbedChat.Address
  alias EmbedChat.Room

  def join("rooms:" <> room_uuid, _payload, socket) do
    cond do
      room = Repo.get_by(Room, uuid: room_uuid) ->
        if authorized?(socket, room) do
          send(self, :after_join)
          EmbedChat.ChannelWatcher.monitor(
            :rooms,
            self(),
            {__MODULE__, :leave, [
                room.id,
                socket.assigns[:user_id],
                socket.assigns.distinct_id]
            })
          {:ok, assign(socket, :room_id, room.id)}
        else
          {:error, %{reason: "unauthorized"}}
        end
      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    online(socket.assigns.room_id, socket.assigns.distinct_id, socket.assigns[:info])
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

  def handle_in("user_info", payload, socket) do
    online(socket.assigns.room_id, socket.assigns.distinct_id, payload)
    broadcast! socket, "user_info", %{uid: socket.assigns.distinct_id, info: payload}
    {:noreply, socket}
  end

  def handle_in("messages", payload, socket) do
    room_id = socket.assigns.room_id
    uuid = messages_owner(payload, socket)

    limit = 50
    cond do
      address = get_address(uuid) ->
        query = from m in Message,
        order_by: [desc: :inserted_at],
        where: m.room_id == ^(room_id) and (m.from_id == ^(address.id) or m.to_id == ^(address.id)),
        limit: ^limit,
        preload: [:from, :to, :from_user]
        messages = Repo.all(query)
        resp = %{uid: uuid, messages: Phoenix.View.render_many(messages,
                                                               EmbedChat.MessageView,
                                                               "message.json")}
        {:reply, {:ok, resp}, socket}
      true ->
        {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_in("contact_list", _payload, socket) do
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
    case new_message(payload, socket) do
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
    broadcast! socket, "user_left", %{uid: distinct_id}

    leave(socket.assigns.room_id, socket.assigns[:user_id], distinct_id)

    {:noreply, socket}
  end

  def leave(room_id, user_id, distinct_id) when is_nil(user_id) do
    # TODO : broadcast "user_left" event
    offline(room_id, distinct_id)
  end

  def leave(room_id, _user_id, distinct_id) do
    # TODO : broadcast "user_left" event
    offline(room_id, distinct_id)
    admin_offline(room_id, distinct_id)
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

  defp online_users(room_id) do
    {:ok, bucket} = user_bucket(room_id)
    Bucket.map(bucket)
  end

  defp online(room_id, distinct_id, info) do
    {:ok, bucket} = user_bucket(room_id)
    Bucket.put(bucket, distinct_id, info)
  end

  defp offline(room_id, distinct_id) do
    {:ok, bucket} = user_bucket(room_id)
    Bucket.delete(bucket, distinct_id)
  end

  defp online_admins(room_id) do
    {:ok, bucket} = admin_bucket(room_id)
    Map.keys(Bucket.map(bucket))
  end

  defp admin_online(room_id, distinct_id) do
    {:ok, bucket} = admin_bucket(room_id)
    Bucket.put(bucket, distinct_id, "")
  end

  defp admin_offline(room_id, distinct_id) do
    {:ok, bucket} = admin_bucket(room_id)
    Bucket.delete(bucket, distinct_id)
  end

  defp user_bucket(room_id) do
    bucket(room_id)
  end

  defp admin_bucket(room_id) do
    bucket("admin:#{room_id}")
  end

  defp bucket(id) do
    reg = Registry
    case Registry.lookup(reg, "rooms:#{id}") do
      {:ok, bucket} ->
        {:ok, bucket}
      :error ->
        Registry.create(reg, "rooms:#{id}")
        Registry.lookup(reg, "rooms:#{id}")
    end
  end

  defp receiver(socket, to) do
    cond do
      socket.assigns[:user_id] ->
        get_or_create_address(to, nil)
      true ->
        admin_address(socket.assigns.room_id)
    end
  end

  defp sender(socket) do
    get_or_create_address(socket.assigns.distinct_id,
                          socket.assigns[:user_id])
  end

  defp admin_address(room_id) do
    # TODO multi users
    admin = List.first online_admins(room_id)
    cond do
      address = get_address(admin) ->
        {:ok, address}
      true ->
        model = %Address{}
        {:error, model}
    end
  end

  defp new_message(payload, socket) do
    room_id = socket.assigns.room_id
    with {:ok, sender} <- sender(socket),
         {_, receiver} <- receiver(socket, payload["to_id"]),
         {:ok, msg} <- create_message(sender, receiver, room_id, payload["body"]),
         msg = Repo.preload(msg, [:from, :to, :from_user]),
         sender = Repo.preload(sender, [:user]),
         resp = Phoenix.View.render(EmbedChat.MessageView,
                                    "message.json",
                                    message: msg, user: sender.user),
     do: {:ok, resp}
  end

  defp create_message(sender, receiver, room_id, text) do
    changeset =
      sender
    |> build_assoc(:outgoing_messages, %{room_id: room_id, to_id: receiver.id})
    |> Message.changeset(%{
          message_type: "message",
          body: text})
    Repo.insert(changeset)
  end

  defp create_admin_address(socket) do
    if socket.assigns[:user_id] do
      get_or_create_address(socket.assigns.distinct_id,
                            socket.assigns[:user_id])
    end
  end

  defp get_or_create_address(distinct_id, user_id) do
    cond do
      address = get_address(distinct_id) ->
        {:ok, address}
      true ->
        create_address(distinct_id, user_id)
    end
  end

  defp get_address(distinct_id) when is_nil(distinct_id) do
    nil
  end

  defp get_address(distinct_id) do
    Repo.get_by(Address, uuid: distinct_id)
  end

  defp create_address(distinct_id, user_id) do
    changeset =
      Address.changeset(%Address{user_id: user_id}, %{uuid: distinct_id})
    case Repo.insert(changeset) do
      {:ok, model} ->
        {:ok, model}
      {:error, changeset} ->
        cond do
          address = get_address(distinct_id) ->
            {:ok, address}
          true ->
            {:error, changeset}
        end
    end
  end

  defp messages_owner(payload, socket) do
    cond do
      payload["uid"] ->
        if socket.assigns[:user_id] do
          payload["uid"]
        else
          socket.assigns.distinct_id
        end
      true ->
        socket.assigns.distinct_id
    end
  end
end
