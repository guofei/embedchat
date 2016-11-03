defmodule EmbedChat.RoomChannel do
  use EmbedChat.Web, :channel
  use Elixometer

  alias EmbedChat.MessageView
  alias EmbedChat.MessageType
  alias EmbedChat.ChannelWatcher
  alias EmbedChat.Room
  alias EmbedChat.RoomChannel.MessageParam
  alias EmbedChat.RoomChannel.SideEffect
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
          {__MODULE__, :leave, [socket.assigns.distinct_id,
                                room,
                                socket.assigns[:current_user]]
          }
        )
        new_socket =
          socket
          |> assign(:room, room)
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
    {:ok, address} = SideEffect.create_or_update_address(socket)
    user = socket.assigns.current_user
    distinct_id = socket.assigns.distinct_id
    room = socket.assigns.room
    SideEffect.admin_online(distinct_id, room.id, user.name, address.id)
    broadcast! socket, "admin_join", %{uid: distinct_id, id: address.id, name: user.name}
  end

  defp visitor_after_join(socket) do
    distinct_id = socket.assigns.distinct_id
    room = socket.assigns.room
    {:ok, address} = SideEffect.create_or_update_address(socket)
    {:ok, log} = SideEffect.create_access_log(address, socket.assigns[:info])
    SideEffect.visitor_online(distinct_id, room.id, address)
    resp = %{
      uid: distinct_id,
      id: address.id,
      name: SideEffect.address_name(address),
      email: SideEffect.address_email(address),
      note: SideEffect.address_note(address),
      info: View.render(UserLogView, "user_log.json", user_log: log)
    }
    broadcast! socket, "user_join", resp
    send_message_history(distinct_id, socket)
    auto_message(socket, log)
  end

  @messages_size 50

  defp send_message_history(uuid, socket) do
    room = socket.assigns.room
    if address = SideEffect.get_address(uuid, room.id) do
      messages = SideEffect.messages(room.id, address, @messages_size)
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
    room = socket.assigns.room
    distinct_id = socket.assigns.distinct_id
    param = %MessageParam{
      room_id: room.id,
      from_uid: distinct_id,
      to_uid: SideEffect.random_online_admin(room.id),
      text: email,
      type: MessageType.email_response
    }
    SideEffect.create_message(param)
    SideEffect.create_visitor(distinct_id, room.id, email)
    {:noreply, socket}
  end

  def handle_event("access_logs", payload, socket) do
    room = socket.assigns.room
    uuid = event_owner(payload, socket)
    if address = SideEffect.get_address(uuid, room.id) do
      logs = SideEffect.accesslogs(address, @log_size)
      resp = View.render_many(logs, UserLogView, "user_log.json")
      {:reply, {:ok, %{uid: uuid, logs: resp}}, socket}
    else
      {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_event("messages", payload, socket) do
    room = socket.assigns.room
    uuid = event_owner(payload, socket)
    if address = SideEffect.get_address(uuid, room.id) do
      messages = SideEffect.messages(room.id, address, @messages_size)
      messages = View.render_many(messages, MessageView, "message.json")
      resp = %{uid: uuid, messages: messages}
      {:reply, {:ok, resp}, socket}
    else
      {:reply, {:error, %{reason: "address error"}}, socket}
    end
  end

  def handle_event("contact_list", _payload, socket) do
    room = socket.assigns.room
    if master?(socket) do
      resp = %{online_users: SideEffect.online_visitors(room.id),
               offline_users: SideEffect.offline_visitors(room.id)}
      {:reply, {:ok, resp}, socket}
    else
      {:reply, {:ok, %{admins: SideEffect.online_admins(room.id)}}, socket}
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
    leave(distinct_id, socket.assigns.room, socket.assigns[:current_user])

    {:noreply, socket}
  end

  def leave(distinct_id, room, is_admin) when is_nil(is_admin) do
    EmbedChat.Endpoint.broadcast! "rooms:#{room.uuid}", "user_left", %{uid: distinct_id}
    SideEffect.visitor_offline(distinct_id, room.id)
  end

  def leave(distinct_id, room, _is_admin) do
    EmbedChat.Endpoint.broadcast! "rooms:#{room.uuid}", "admin_left", %{uid: distinct_id}
    SideEffect.admin_offline(distinct_id, room.id)
  end

  defp event_owner(payload, socket) do
    if payload["uid"] && master?(socket) do
      payload["uid"]
    else
      socket.assigns.distinct_id
    end
  end

  defp master?(socket) do
    socket.assigns[:current_user]
  end

  # Add authorization logic here as required.
  defp authorized?(socket, room) do
    if user = socket.assigns[:current_user] do
      room = Repo.preload room, :users
      users = room.users
      Enum.any?(users, &(&1.id == user.id))
    else
      true
    end
  end

  # TODO remove random
  defp auto_message(socket, %UserLog{} = log) do
    distinct_id = socket.assigns.distinct_id
    room = socket.assigns.room
    messages = SideEffect.auto_messages(room.id, log)
    Enum.each(messages, fn (msg) ->
      param = message_param(msg, room, distinct_id)
      case create_message_and_view(param) do
        {:ok, resp} ->
          push socket, "new_message", resp
      end
    end)
  end

  defp message_param(msg, room, distinct_id) do
    %MessageParam{
      room_id: room.id,
      from_uid: SideEffect.random_admin(room),
      to_uid: distinct_id,
      text: msg.message
    }
  end

  defp request_visitor_email(socket) do
    room = socket.assigns.room
    distinct_id = socket.assigns.distinct_id
    if SideEffect.can_request_email?(room.id, distinct_id) do
      param = %MessageParam{
        room_id: room.id,
        from_uid: SideEffect.random_admin(room),
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
    room = socket.assigns.room
    master_uid = SideEffect.random_online_admin(room.id)
    if master_uid == nil do
      SideEffect.send_notification_mail(room.id, text)
    end
    param = %MessageParam{
      room_id: room.id,
      from_uid: socket.assigns.distinct_id,
      to_uid: master_uid,
      text: text
    }
    create_message_and_view(param)
  end

  defp new_message_from_master(socket, to_uid, text) do
    param = %MessageParam{
      room_id: socket.assigns.room.id,
      from_uid: socket.assigns.distinct_id,
      to_uid: to_uid,
      text: text
    }
    create_message_and_view(param)
  end

  defp create_message_and_view(%MessageParam{} = param) do
    {:ok, msg} = SideEffect.create_message(param)
    msg = Repo.preload(msg, [:from, :to, :from_user])
    resp = View.render(MessageView, "message.json", message: msg)
    {:ok, resp}
  end
end
