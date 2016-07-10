defmodule EmbedChat.RoomChannel.SideEffect do
  alias EmbedChat.Address
  alias EmbedChat.AutoMessageConfig
  alias EmbedChat.Repo
  alias EmbedChat.Message
  alias EmbedChat.MessageView
  alias EmbedChat.Room.Bucket
  alias EmbedChat.Room.Registry
  alias EmbedChat.User
  alias EmbedChat.UserLog
  alias EmbedChat.UserLogView
  alias EmbedChat.UserRoom
  alias Phoenix.View

  @max_offline_size 10
  @max_online_size 20

  import Ecto.Query, only: [from: 2]

  def create_access_log(%Address{} = address, payload) do
    address
    |> Ecto.build_assoc(:user_logs)
    |> UserLog.changeset(payload)
    |> Repo.insert
  end

  def messages(room_id, address, limit) do
    query = from m in Message,
      order_by: [desc: :inserted_at],
      where: m.room_id == ^(room_id) and (m.from_id == ^(address.id) or m.to_id == ^(address.id)),
      limit: ^limit,
      preload: [:from, :to, :from_user]
    Repo.all(query)
  end

  def new_message_visitor_to_master(%{"from_id" => from_uid, "body" => msg_text}, room_id) do
    master_uid = random_admin(room_id)
    with {:ok, sender} <- visitor_sender(from_uid),
         {:ok, receiver} <- master_receiver(master_uid),
         {:ok, msg} <- create_message(sender, receiver, room_id, msg_text),
           msg = Repo.preload(msg, [:from, :to, :from_user]),
           sender = Repo.preload(sender, [:user]),
           resp = View.render(MessageView, "message.json", message: msg, user: sender.user),
      do: {:ok, resp}
  end

  def new_message_master_to_visitor(%{"to_id" => to_uid, "body" => msg_text}, room_id) do
    master_uid = random_admin(room_id)
    with {:ok, sender} <- master_sender(master_uid),
         {:ok, receiver} <- visitor_receiver(to_uid),
         {:ok, msg} <- create_message(sender, receiver, room_id, msg_text),
           msg = Repo.preload(msg, [:from, :to, :from_user]),
           sender = Repo.preload(sender, [:user]),
           resp = View.render(MessageView, "message.json", message: msg, user: sender.user),
      do: {:ok, resp}
  end

  def auto_messages(room_id, %UserLog{} = log) do
    all_messages = Repo.all(from m in AutoMessageConfig, where: m.room_id == ^room_id)
    EmbedChat.AutoMessageConfig.match(all_messages, log)
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

  defp admin_address(admin) do
    # TODO multi users
    if address = get_address(admin) do
      {:ok, address}
    else
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

  def create_address(socket) do
    get_or_create_address(socket.assigns.distinct_id, socket.assigns[:user_id])
  end

  defp get_or_create_address(distinct_id, user_id) do
    if address = get_address(distinct_id) do
      {:ok, address}
    else
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
        if address = get_address(distinct_id) do
          {:ok, address}
        else
          {:error, changeset}
        end
    end
  end

  def messages_owner(payload, socket) do
    if payload["uid"] && socket.assigns[:user_id] do
      payload["uid"]
    else
      socket.assigns.distinct_id
    end
  end

  @max_user_log 20

  def offline_visitors(room_id) do
    {:ok, offbkt} = offline_visitor_bucket(room_id)
    visitors(offbkt, @max_offline_size)
  end

  def online_visitors(room_id) do
    {:ok, bkt} = visitor_bucket(room_id)
    visitors(bkt, @max_online_size)
  end

  defp visitors(bucket, limit) do
    bucket
    |> Bucket.map
    |> Enum.take(limit)
    |> Enum.map(fn {distinct_id, address_id} ->
      logs = Repo.all(UserLog.for_address_id(UserLog, address_id, @max_user_log))
      resp = View.render_many(logs, UserLogView, "user_log.json")
      {distinct_id, resp}
    end)
    |> Enum.into(%{})
  end

  def visitor_online(room_id, distinct_id, address_id) do
    {:ok, bkt} = visitor_bucket(room_id)
    Bucket.put(bkt, distinct_id, address_id)

    {:ok, offbkt} = offline_visitor_bucket(room_id)
    Bucket.delete(offbkt, distinct_id)
  end

  def visitor_offline(room_id, distinct_id) do
    {:ok, bkt} = visitor_bucket(room_id)
    address_id = Bucket.get(bkt, distinct_id)
    Bucket.delete(bkt, distinct_id)

    if address_id do
      {:ok, offbkt} = offline_visitor_bucket(room_id)
      Bucket.put(offbkt, distinct_id, address_id, @max_offline_size)
    end
  end

  def online_admins(room_id) do
    {:ok, bkt} = admin_bucket(room_id)
    Bucket.map(bkt)
  end

  defp room_admin_address(room_id) do
    Address
    |> Address.latest_for_room(room_id)
    |> Repo.one
  end

  defp random_admin(room_id) do
    cond do
      admin = random_online_admin(room_id) ->
        admin
      address = room_admin_address(room_id) ->
        address.uuid
      true ->
        nil
    end
  end

  defp random_online_admin(room_id) do
    admins = online_admins(room_id)
    if Enum.empty?(admins) do
      nil
    else
      {admin, _} = Enum.random admins
      admin
    end
  end

  def admin_online(room_id, distinct_id, user) do
    {:ok, bkt} = admin_bucket(room_id)
    Bucket.put(bkt, distinct_id, %{id: user.id, name: user.name})
  end

  def admin_offline(room_id, distinct_id) do
    {:ok, bkt} = admin_bucket(room_id)
    Bucket.delete(bkt, distinct_id)
  end

  defp visitor_bucket(room_id) do
    bucket("visitor:#{room_id}")
  end

  defp offline_visitor_bucket(room_id) do
    bucket("offvisitor:#{room_id}")
  end

  defp admin_bucket(room_id) do
    bucket("admin:#{room_id}")
  end

  defp bucket(id) do
    reg = Registry
    case Registry.lookup(reg, "rooms:#{id}") do
      {:ok, bkt} ->
        {:ok, bkt}
      :error ->
        Registry.create(reg, "rooms:#{id}")
        Registry.lookup(reg, "rooms:#{id}")
    end
  end
end
