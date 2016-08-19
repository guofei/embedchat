defmodule EmbedChat.RoomChannel do
  use EmbedChat.Web, :channel
  use Elixometer

  alias EmbedChat.MessageView
  alias EmbedChat.MessageType
  alias EmbedChat.ChannelWatcher
  alias EmbedChat.Room
  alias EmbedChat.RoomChannel.MessageParam
  alias EmbedChat.RoomChannel.SideEffect
  alias EmbedChat.User
  alias EmbedChat.UserLog
  alias EmbedChat.UserLogView
  alias Phoenix.View

  @timed(key: "channel_resp_time")
  def join("rooms:" <> room_uuid, payload, socket) do
    update_spiral("channel_event_count", 1)
    if room = Repo.get_by(Room, uuid: room_uuid) do
      if authorized?(socket, room) do
        send(self, :after_join)
        ChannelWatcher.monitor(
          :rooms,
          self,
          {__MODULE__, :leave, [room.id,
                                room.uuid,
                                socket.assigns[:user_id],
                                socket.assigns.distinct_id]
          }
        )
        new_socket =
          socket
          |> assign(:room_id, room.id)
          |> assign(:room_uuid, room.uuid)
          |> assign(:info, payload)
        {:ok, new_socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @timed(key: "channel_resp_time")
  def handle_info(:after_join, socket) do
    update_spiral("channel_event_count", 1)
    if master?(socket) do
      master_after_join(socket)
    else
      visitor_after_join(socket)
    end
    {:noreply, socket}
  end

  defp master_after_join(socket) do
    user = Repo.get!(User, socket.assigns.user_id)
    {:ok, address} = SideEffect.create_or_update_address(socket)
    SideEffect.admin_online(socket.assigns.room_id, socket.assigns.distinct_id, user, address)
    broadcast! socket, "admin_join", %{uid: socket.assigns.distinct_id, id: address.id, name: user.name}
  end

  defp visitor_after_join(socket) do
    distinct_id = socket.assigns.distinct_id
    room_id = socket.assigns.room_id
    {:ok, address} = SideEffect.create_or_update_address(socket)
    {:ok, log} = SideEffect.create_access_log(address, socket.assigns[:info])
    SideEffect.visitor_online(room_id, distinct_id, address.id)
    resp = %{uid: distinct_id, id: address.id, info: View.render(UserLogView, "user_log.json", user_log: log)}
    broadcast! socket, "user_join", resp
    send_message_history(distinct_id, socket)
    auto_message(socket, room_id, distinct_id, log)
  end

  @messages_size 50

  defp send_message_history(uuid, socket) do
    room_id = socket.assigns.room_id
    if address = SideEffect.get_address(uuid, room_id) do
      messages = SideEffect.messages(room_id, address, @messages_size)
      messages = View.render_many(messages, MessageView, "message.json")
      resp = %{uid: uuid, messages: messages}
      push socket, "messages", resp
    end
  end

  # Have all channel messages go to a single point
  @timed(key: "channel_resp_time")
  def handle_in(event, params, socket) do

    # Use a different named function so we can measure messages
    response = handle_event(event, params, socket)

    # update event count
    update_spiral("channel_event_count", 1)

    response
  end

  @log_size 50

  def handle_event("email", email, socket) do
    room_id = socket.assigns.room_id
    SideEffect.create_visitor(socket.assigns.distinct_id, room_id, email)
    param = %MessageParam{
      room_id: room_id,
      from_uid: socket.assigns.distinct_id,
      to_uid: SideEffect.random_online_admin(room_id),
      text: email,
      type: MessageType.email_response
    }
    SideEffect.create_message(param)
    {:noreply, socket}
  end

  def handle_event("access_logs", payload, socket) do
    room_id = socket.assigns.room_id
    uuid = event_owner(payload, socket)
    if address = SideEffect.get_address(uuid, room_id) do
      logs = SideEffect.accesslogs(address, @log_size)
      resp = View.render_many(logs, UserLogView, "user_log.json")
      {:reply, {:ok, %{uid: uuid, logs: resp}}, socket}
    else
      {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_event("messages", payload, socket) do
    room_id = socket.assigns.room_id
    uuid = event_owner(payload, socket)
    if address = SideEffect.get_address(uuid, room_id) do
      messages = SideEffect.messages(room_id, address, @messages_size)
      messages = View.render_many(messages, MessageView, "message.json")
      resp = %{uid: uuid, messages: messages}
      {:reply, {:ok, resp}, socket}
    else
      {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_event("contact_list", _payload, socket) do
    if master?(socket) do
      resp = %{online_users: SideEffect.online_visitors(socket.assigns.room_id),
               offline_users: SideEffect.offline_visitors(socket.assigns.room_id)}
      {:reply, {:ok, resp}, socket}
    else
      {:reply, {:ok, %{admins: SideEffect.online_admins(socket.assigns.room_id)}}, socket}
    end
  end

  def handle_event("new_message", payload, socket) do
    case new_message(payload, socket) do
      {:ok, resp} ->
        broadcast! socket, "new_message", resp
        if !master?(socket) do
          request_visitor_email(socket)
        end
        {:reply, {:ok, resp}, socket}
      {:error, changeset} ->
        {:reply, {:error, Enum.into(changeset.errors, %{})}, socket}
    end
  end

  intercept ["new_message"]

  # TODO maybe better to def join("users:" <> user_id, _params, socket)
  # http://stackoverflow.com/questions/37680988/phoenix-channels-send-push-to-a-particular-client
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
    SideEffect.visitor_offline(room_id, distinct_id)
  end

  def leave(room_id, room_uuid, _user_id, distinct_id) do
    EmbedChat.Endpoint.broadcast! "rooms:#{room_uuid}", "admin_left", %{uid: distinct_id}
    SideEffect.admin_offline(room_id, distinct_id)
  end

  defp event_owner(payload, socket) do
    if payload["uid"] && master?(socket) do
      payload["uid"]
    else
      socket.assigns.distinct_id
    end
  end

  defp master?(socket) do
    socket.assigns[:user_id]
  end

  # Add authorization logic here as required.
  defp authorized?(socket, room) do
    if user_id = socket.assigns[:user_id] do
      room = Repo.preload room, :users
      users = room.users
      user = Repo.get!(User, user_id)
      Enum.any?(users, &(&1.id == user.id))
    else
      true
    end
  end

  # TODO remove random
  defp auto_message(socket, room_id, distinct_id, %UserLog{} = log) do
    messages = SideEffect.auto_messages(room_id, log)
    Enum.each(messages, fn (msg) ->
      param = %MessageParam{room_id: room_id, from_uid: SideEffect.random_admin(room_id), to_uid: distinct_id, text: msg.message}
      case create_message_and_view(param) do
        {:ok, resp} ->
          push socket, "new_message", resp
      end
    end)
  end

  defp request_visitor_email(socket) do
    room_id = socket.assigns.room_id
    distinct_id = socket.assigns.distinct_id
    if SideEffect.can_request_email?(room_id, distinct_id) do
      param = %MessageParam{
        room_id: room_id,
        from_uid: SideEffect.random_admin(room_id),
        to_uid: distinct_id,
        text: "Get replies by email",
        type: EmbedChat.MessageType.email_request
      }
      case create_message_and_view(param) do
        {:ok, resp} ->
          push socket, "new_message", resp
        {:error, _} ->
          nil
      end
    end
  end

  defp new_message(%{"to_id" => to_uid, "body" => msg_text}, socket) do
    if master?(socket) do
      new_message_from_master(socket, to_uid, msg_text)
    else
      new_message_from_visitor(socket, msg_text)
    end
  end

  # TODO remove random
  defp new_message_from_visitor(socket, text) do
    room_id = socket.assigns.room_id
    master_uid = SideEffect.random_online_admin(room_id)
    if master_uid == nil do
      SideEffect.send_notification_mail(room_id, text)
    end
    param = %MessageParam{
      room_id: socket.assigns.room_id,
      from_uid: socket.assigns.distinct_id,
      to_uid: master_uid,
      text: text
    }
    create_message_and_view(param)
  end

  defp new_message_from_master(socket, to_uid, text) do
    param = %MessageParam{
      room_id: socket.assigns.room_id,
      from_uid: socket.assigns.distinct_id,
      to_uid: to_uid,
      text: text
    }
    create_message_and_view(param)
  end

  def create_message_and_view(%MessageParam{} = param) do
    {:ok, msg} = SideEffect.create_message(param)
    msg = Repo.preload(msg, [:from, :to, :from_user])
    resp = View.render(MessageView, "message.json", message: msg)
    {:ok, resp}
  end
end
