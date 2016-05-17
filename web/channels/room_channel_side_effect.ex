defmodule EmbedChat.RoomChannelSF do
  alias EmbedChat.Address
  alias EmbedChat.Repo
  alias EmbedChat.Message
  alias EmbedChat.MessageView
  alias Phoenix.View

  defp receiver(socket, to, admin) do
    cond do
      socket.assigns[:user_id] ->
        get_or_create_address(to, nil)
      true ->
        admin_address(admin)
    end
  end

  defp sender(socket) do
    get_or_create_address(socket.assigns.distinct_id, socket.assigns[:user_id])
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

  def new_message(payload, socket, admin) do
    room_id = socket.assigns.room_id
    with {:ok, sender} <- sender(socket),
         {_, receiver} <- receiver(socket, payload["to_id"], admin),
         {:ok, msg} <- create_message(sender, receiver, room_id, payload["body"]),
           msg = Repo.preload(msg, [:from, :to, :from_user]),
           sender = Repo.preload(sender, [:user]),
           resp = View.render(MessageView, "message.json", message: msg, user: sender.user),
      do: {:ok, resp}
  end

  defp create_message(sender, receiver, room_id, text) do
    changeset =
      sender
      |> Ecto.build_assoc(:outgoing_messages, %{room_id: room_id, to_id: receiver.id})
      |> Message.changeset(%{
          message_type: "message",
          body: text})
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
end
