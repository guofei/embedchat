defmodule EmbedChatWeb.Chat do
  import Ecto.Query

  alias EmbedChat.Address
  alias EmbedChatWeb.Chat
  alias EmbedChat.Message
  alias EmbedChat.MessageType
  alias EmbedChatWeb.MessageView
  alias EmbedChat.Repo
  alias Phoenix.View

  defstruct [:room_id, :from_uid, :to_uid, :text, type: MessageType.normal()]

  def master_to_visitor(%Chat{} = chat) do
    if chat.from_uid do
      create_message chat
    else
      from_address = room_admin_address(chat.room_id)
      new_chat = %{chat | from_uid: from_address.uuid}
      create_message new_chat
    end
  end

  def visitor_to_master(%Chat{} = chat) do
    if chat.to_uid do
      create_message chat
    else
      to_address = room_admin_address(chat.room_id)
      new_chat = %{chat | to_uid: to_address.uuid}
      create_message new_chat
    end
  end

  def response({:ok, message}) do
    msg =
      message
      |> Repo.preload([:from, :to, :from_user])
    resp = View.render(MessageView, "message.json", message: msg)
    {:ok, resp}
  end

  def response({:error, reason}) do
    {:error, reason}
  end

  defp create_message(%Chat{} = param) do
    sender = get_address(param.from_uid, param.room_id)
    receiver = get_address(param.to_uid, param.room_id)
    create_message(sender, receiver, param.room_id, param.text, param.type)
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

  def get_address(distinct_id, room_id) when is_nil(distinct_id) or is_nil(room_id) do
    nil
  end

  def get_address(distinct_id, room_id) do
    Repo.get_by(Address, uuid: distinct_id, room_id: room_id)
  end

  # TODO remove random
  defp room_admin_address(room_id) do
    Address
    |> where([a], a.room_id == ^room_id)
    |> where([a], not is_nil(a.user_id))
    |> limit(1)
    |> Repo.one
  end
end
