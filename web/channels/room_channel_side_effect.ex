defmodule EmbedChat.RoomChannelSF do
  alias EmbedChat.Address
  alias EmbedChat.Repo
  alias EmbedChat.Message
  alias EmbedChat.MessageView
  alias EmbedChat.Room
  alias EmbedChat.Room.Bucket
  alias EmbedChat.Room.Registry
  alias Phoenix.View

  # send to master user if the to_id is nil
  def new_message(%{"to_id" => to_uid, "body" => msg_text}, socket) do
    room_id = socket.assigns.room_id
    cond do
      socket.assigns[:user_id] ->
        new_message_master_to_visitor(%{"to_id" => to_uid, "body" => msg_text}, room_id)
      true ->
        distinct_id = socket.assigns.distinct_id
        new_message_visitor_to_master(%{"from_id" => distinct_id, "body" => msg_text}, room_id)
    end
    # room_id = socket.assigns.room_id
    # distinct_id = socket.assigns.distinct_id
    # user_id = socket.assigns[:user_id]
    # with {:ok, sender} <- sender(distinct_id, user_id),
    #      {_, receiver} <- receiver(user_id, to_uid, online_master),
    #      {:ok, msg} <- create_message(sender, receiver, room_id, msg_text),
    #        msg = Repo.preload(msg, [:from, :to, :from_user]),
    #        sender = Repo.preload(sender, [:user]),
    #        resp = View.render(MessageView, "message.json", message: msg, user: sender.user),
    #   do: {:ok, resp}
  end

  def new_message_visitor_to_master(%{"from_id" => distinct_id, "body" => msg_text}, room_id) do
    online_master = random_online_admin(room_id)
    with {:ok, sender} <- visitor_sender(distinct_id),
         {_, receiver} <- master_receiver(online_master),
         {:ok, msg} <- create_message(sender, receiver, room_id, msg_text),
           msg = Repo.preload(msg, [:from, :to, :from_user]),
           sender = Repo.preload(sender, [:user]),
           resp = View.render(MessageView, "message.json", message: msg, user: sender.user),
      do: {:ok, resp}
  end

  def new_message_master_to_visitor(%{"to_id" => to_uid, "body" => msg_text}, room_id) do
    online_master = random_online_admin(room_id)
    with {_, sender} <- master_sender(online_master),
         {:ok, receiver} <- visitor_receiver(to_uid),
         {:ok, msg} <- create_message(sender, receiver, room_id, msg_text),
           msg = Repo.preload(msg, [:from, :to, :from_user]),
           sender = Repo.preload(sender, [:user]),
           resp = View.render(MessageView, "message.json", message: msg, user: sender.user),
      do: {:ok, resp}
  end

  defp receiver(nil, _to, admin) do
    admin_address(admin)
  end

  defp receiver(_user_id, to, _admin) do
    get_or_create_address(to, nil)
  end

  defp visitor_receiver(to) do
    get_or_create_address(to, nil)
  end

  defp master_receiver(admin) do
    admin_address(admin)
  end

  defp visitor_sender(distinct_id) do
    get_or_create_address(distinct_id, nil)
  end

  defp master_sender(admin) do
    admin_address(admin)
  end

  defp sender(distinct_id, user_id) do
    get_or_create_address(distinct_id, user_id)
  end

  defp admin_address(admin) do
    # TODO multi users
    cond do
      address = get_address(admin) ->
        {:ok, address}
      true ->
        {:error, %Address{}}
    end
  end

  defp create_message(sender, receiver, room_id, text) do
    changeset =
      Message.changeset(
        %Message{room_id: room_id, from_id: sender.id, to_id: receiver.id},
        %{message_type: "message", body: text}
      )
      Repo.insert(changeset)
  end

  def create_admin_address(socket) do
    if socket.assigns[:user_id] do
      get_or_create_address(socket.assigns.distinct_id, socket.assigns[:user_id])
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

  def get_address(distinct_id) when is_nil(distinct_id) do
    nil
  end

  def get_address(distinct_id) do
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

  def messages_owner(payload, socket) do
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

  def online_visitors(room_id) do
    {:ok, bucket} = visitor_bucket(room_id)
    Bucket.map(bucket)
  end

  def visitor_update(room_id, distinct_id, info) do
    visitor_online(room_id, distinct_id, info)
  end

  def visitor_online(room_id, distinct_id, info) do
    {:ok, bucket} = visitor_bucket(room_id)
    Bucket.put(bucket, distinct_id, info)
  end

  def visitor_offline(room_id, distinct_id) do
    {:ok, bucket} = visitor_bucket(room_id)
    Bucket.delete(bucket, distinct_id)
  end

  def online_admins(room_id) do
    {:ok, bucket} = admin_bucket(room_id)
    Bucket.map(bucket)
  end

  def random_online_admin(room_id) do
    admins = online_admins(room_id)
    if Enum.empty?(admins) do
      room = Repo.get Room, room_id
      user = Repo.one Ecto.assoc(room, :users)
      user = Repo.preload(user, [:addresses])
      address = List.first(user.addresses)
      if address do
        address.uuid
      else
        nil
      end
    else
      {admin, _ } = Enum.random admins
      admin
    end
  end

  def admin_online(room_id, distinct_id, user) do
    {:ok, bucket} = admin_bucket(room_id)
    Bucket.put(bucket, distinct_id, %{id: user.id, name: user.name})
  end

  def admin_offline(room_id, distinct_id) do
    {:ok, bucket} = admin_bucket(room_id)
    Bucket.delete(bucket, distinct_id)
  end

  defp visitor_bucket(room_id) do
    bucket("visitor:#{room_id}")
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
end
