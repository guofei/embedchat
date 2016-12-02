defmodule EmbedChat.RoomChannel.MessageParam do
  alias EmbedChat.MessageType
  defstruct [:room_id, :from_uid, :to_uid, :text, type: MessageType.normal()]
end

defmodule EmbedChat.RoomChannel.SideEffect do
  alias EmbedChat.Address
  alias EmbedChat.AutoMessageConfig
  alias EmbedChat.Repo
  alias EmbedChat.Message
  alias EmbedChat.Room
  alias EmbedChat.Room.Bucket
  alias EmbedChat.Room.Registry
  alias EmbedChat.RoomChannel.MessageParam
  alias EmbedChat.User
  alias EmbedChat.Track

  import Ecto.Query, only: [from: 2]

  def create_access_log(%Address{} = address, payload) do
    address
    |> Ecto.build_assoc(:tracks)
    |> Track.changeset(payload)
    |> Repo.insert
  end

  def messages(room_id, address, limit) do
    if show_request_email?(room_id, address.uuid) do
      Message
      |> Message.visitor_history(room_id, address.id, limit)
      |> Ecto.Query.preload([:from, :to, :from_user])
      |> Repo.all
    else
      Message
      |> Message.master_history(room_id, address.id, limit)
      |> Ecto.Query.preload([:from, :to, :from_user])
      |> Repo.all
    end
  end

  def accesslogs(address, limit) do
    query = from u in Track,
      where: u.address_id == ^(address.id),
      order_by: [desc: :inserted_at],
      limit: ^limit
    Repo.all(query)
  end

  def send_notification_mail(room_id, text) do
    room =
      Room
      |> Repo.get(room_id)
      |> Repo.preload(:users)
    Enum.each(room.users, fn(user) ->
      user
      |> EmbedChat.UserEmail.send_msg_notification(text)
      |> EmbedChat.Mailer.deliver_later
    end)
  end

  def create_message(%MessageParam{} = param) do
    sender = get_address(param.from_uid, param.room_id)
    receiver = get_address(param.to_uid, param.room_id)
    create_message(sender, receiver, param.room_id, param.text, param.type)
  end

  def auto_messages(room_id, %Track{} = log) do
    all_messages = Repo.all(from m in AutoMessageConfig, where: m.room_id == ^room_id)
    EmbedChat.AutoMessageConfig.match(all_messages, log)
  end

  defp create_message(sender, receiver, room_id, text, type) when is_nil(receiver) do
    changeset =
      Message.changeset(
        %Message{room_id: room_id, from_id: sender.id, to_id: nil},
        %{body: text, type: type}
      )
    Repo.insert(changeset)
  end

  defp create_message(sender, receiver, room_id, text, type) do
    changeset =
      Message.changeset(
        %Message{room_id: room_id, from_id: sender.id, to_id: receiver.id},
        %{body: text, type: type}
      )
    Repo.insert(changeset)
  end

  defp create_or_update_address(uuid, room_id, user_id) do
    struct =
      case Repo.get_by(Address, room_id: room_id, uuid: uuid) do
        nil  -> %Address{}
        address -> address
      end
    struct
    |> Address.changeset(%{room_id: room_id, uuid: uuid, user_id: user_id})
    |> Repo.insert_or_update(force: true)
  end

  def create_or_update_address(socket) do
    user_id = if user = socket.assigns[:current_user] do
      user.id
    else
      nil
    end
    create_or_update_address(
      socket.assigns.distinct_id,
      socket.assigns.room.id,
      user_id)
  end

  def get_address(distinct_id, room_id) when is_nil(distinct_id) or is_nil(room_id) do
    nil
  end

  def get_address(distinct_id, room_id) do
    Repo.get_by(Address, uuid: distinct_id, room_id: room_id)
  end

  def address_email(address) do
    address = Repo.preload(address, [:visitor])
    if address.visitor do
      address.visitor.email
    else
      nil
    end
  end

  def address_name(address) do
    address = Repo.preload(address, [:visitor])
    if address.visitor do
      address.visitor.name
    else
      nil
    end
  end

  def address_note(address) do
    address = Repo.preload(address, [:visitor])
    if address.visitor do
      address.visitor.note
    else
      nil
    end
  end

  @max_offline_size 10
  @max_online_size 20
  @max_track 20

  # return %{"uuid1" => %{id: id, name: name, email: "name@domain"}, "uuid2" => %{id: id, name: name, email: nil, note: note}}
  def offline_visitors(room_id) do
    {:ok, bkt} = visitor_bucket(room_id)
    onlines = Bucket.map(bkt)
    online_size = Enum.count(onlines)

    Address
    |> Address.latest_for_room(room_id, @max_offline_size + online_size)
    |> Ecto.Query.preload([:visitor])
    |> Repo.all
    |> Enum.filter(fn address -> !Map.has_key?(onlines, address.uuid) end)
    |> Enum.map(fn a ->
      {a.uuid, %{id: a.id, name: address_name(a), email: address_email(a), note: address_note(a)}}
    end)
    |> Enum.into(%{})
  end

  # return %{"uuid1" => %{id: id, name: name, email: "name@domain"}, "uuid2" => %{id: id, name: name, email: nil, note: "note"}}
  def online_visitors(room_id) do
    {:ok, bkt} = visitor_bucket(room_id)
    map = Bucket.map(bkt)
    id_list = Enum.map(map, fn {_k, v} -> v end)
    Address
    |> Address.where_in(room_id, id_list)
    |> Ecto.Query.preload([:visitor])
    |> Repo.all
    |> Enum.map(fn a ->
      {a.uuid, %{id: a.id, name: address_name(a), email: address_email(a), note: address_note(a)}}
    end)
    |> Enum.into(%{})
  end

  def visitor_online(distinct_id, room_id, address) do
    {:ok, bkt} = visitor_bucket(room_id)
    Bucket.put(bkt, distinct_id, address.id)
  end

  def visitor_offline(distinct_id, room_id) do
    {:ok, bkt} = visitor_bucket(room_id)
    Bucket.delete(bkt, distinct_id)
  end

  # return %{"uuid1" => %{id: id, name: name}, "uuid2" => %{id: id, name: name}}
  def online_admins(room_id) do
    {:ok, bkt} = admin_bucket(room_id)
    Bucket.map(bkt)
  end

  defp online_admins_empty?(room_id) do
    admins = online_admins(room_id)
    Enum.empty?(admins)
  end

  defp show_request_email?(room_id, uuid) do
    if online_admins_empty?(room_id) do
      visitor_count =
        Address
        |> Address.visitor_count(room_id, uuid)
        |> Repo.one
      visitor_count <= 0
    else
      false
    end
  end

  def can_request_email?(room_id, uuid) do
    if show_request_email?(room_id, uuid) do
      email_request_count =
        Message
        |> Message.email_request_count(room_id, uuid)
        |> Repo.one
      email_request_count <= 0
    else
      false
    end
  end

  defp room_admin_address(room) do
    user =
      User
      |> User.latest_for_room(room)
      |> Repo.one

    Address
    |> Address.latest_for_room_master(user.id, room.id)
    |> Repo.one
  end

  def random_admin(room) do
    cond do
      admin = random_online_admin(room) ->
        admin
      address = room_admin_address(room) ->
        address.uuid
      true ->
        nil
    end
  end

  def random_online_admin(room) do
    admins = online_admins(room.id)
    if Enum.empty?(admins) do
      nil
    else
      {admin, _} = Enum.random admins
      admin
    end
  end

  def admin_online(distinct_id, room_id, user_name, address_id) do
    {:ok, bkt} = admin_bucket(room_id)
    Bucket.put(bkt, distinct_id, %{id: address_id, name: user_name})
  end

  def admin_offline(distinct_id, room_id) do
    {:ok, bkt} = admin_bucket(room_id)
    Bucket.delete(bkt, distinct_id)
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
      {:ok, bkt} ->
        {:ok, bkt}
      :error ->
        Registry.create(reg, "rooms:#{id}")
        Registry.lookup(reg, "rooms:#{id}")
    end
  end
end
