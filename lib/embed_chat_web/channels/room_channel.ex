defmodule EmbedChatWeb.RoomChannel do
  use EmbedChatWeb, :channel

  alias EmbedChat.ChannelWatcher
  alias EmbedChat.Room
  alias EmbedChatWeb.Chat, as: ChatWeb
  alias EmbedChatWeb.MessageView
  alias EmbedChatWeb.RoomChannel.SideEffect
  alias EmbedChatWeb.TrackView
  alias Phoenix.View

  def join("rooms:" <> room_uuid, _payload, socket) do
    if room = Repo.get_by(Room, uuid: room_uuid) do
      if authorized?(socket, room) do
        send(self(), :after_join)
        ChannelWatcher.monitor(
          :rooms,
          self(),
          {__MODULE__, :leave, [socket.assigns.distinct_id,
                                room,
                                socket.assigns[:current_user]]
          }
        )
        new_socket =
          socket
          |> assign(:room, room)
        {:ok, new_socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    if operator?(socket) do
      operator_after_join(socket)
    else
      visitor_after_join(socket)
    end
    {:noreply, socket}
  end

  defp operator_after_join(socket) do
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
    SideEffect.visitor_online(distinct_id, room.id, address)
    resp = %{
      uid: distinct_id,
      id: address.id,
      name: SideEffect.address_name(address),
      email: SideEffect.address_email(address),
      note: SideEffect.address_note(address)
    }
    broadcast! socket, "user_join", resp
  end

  @messages_size 50

  # Have all channel messages go to a single point
  def handle_in(event, params, socket) do
    # Use a different named function so we can measure messages
    response = handle_event(event, params, socket)
    response
  end

  @log_size 20

  def handle_event("access_logs", payload, socket) do
    room = socket.assigns.room
    uuid = event_owner(payload, socket)
    if address = SideEffect.get_address(uuid, room.id) do
      logs = SideEffect.accesslogs(address, @log_size)
      resp = View.render_many(logs, TrackView, "track.json")
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
    if operator?(socket) do
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
        if !operator?(socket) do
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
    EmbedChatWeb.Endpoint.broadcast! "rooms:#{room.uuid}", "user_left", %{uid: distinct_id}
    SideEffect.visitor_offline(distinct_id, room.id)
  end

  def leave(distinct_id, room, _is_admin) do
    EmbedChatWeb.Endpoint.broadcast! "rooms:#{room.uuid}", "admin_left", %{uid: distinct_id}
    SideEffect.admin_offline(distinct_id, room.id)
  end

  defp event_owner(payload, socket) do
    if payload["uid"] && operator?(socket) do
      payload["uid"]
    else
      socket.assigns.distinct_id
    end
  end

  defp operator?(socket) do
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

  defp request_visitor_email(socket) do
    room = socket.assigns.room
    distinct_id = socket.assigns.distinct_id
    if SideEffect.can_request_email?(room.id, distinct_id) do
      param = %ChatWeb{
        room_id: room.id,
        to_uid: distinct_id,
        text: "Get replies by email",
        type: EmbedChat.MessageType.email_request
      }
      msg_resp =
        param
        |> ChatWeb.operator_to_visitor
        |> ChatWeb.response
      case msg_resp do
        {:ok, resp} ->
          push socket, "new_message", resp
        {:error, _} ->
          nil
      end
    end
  end

  defp new_message(%{"to_id" => to_uid, "body" => msg_text}, socket) do
    if operator?(socket) do
      new_message_from_operator(socket, to_uid, msg_text)
    else
      new_message_from_visitor(socket, msg_text)
    end
  end

  defp new_message_from_visitor(socket, text) do
    param = %ChatWeb{
      room_id: socket.assigns.room.id,
      from_uid: socket.assigns.distinct_id,
      text: text
    }
    param
    |> offline_email(socket)
    |> ChatWeb.visitor_to_operator
    |> ChatWeb.response
  end

  # TODO remove random
  defp offline_email(%ChatWeb{} = chat, socket) do
    room = socket.assigns.room
    operator_uid =
      case SideEffect.random_online_admin(room) do
        nil ->
          SideEffect.send_notification_mail(room.id, chat.text)
          nil
        uid ->
          uid
      end
    %{chat | to_uid: operator_uid}
  end

  defp new_message_from_operator(socket, to_uid, text) do
    param = %ChatWeb{
      room_id: socket.assigns.room.id,
      from_uid: socket.assigns.distinct_id,
      to_uid: to_uid,
      text: text
    }
    param
    |> ChatWeb.operator_to_visitor
    |> ChatWeb.response
  end
end
