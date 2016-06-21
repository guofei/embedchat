defmodule EmbedChat.MessageView do
  use EmbedChat.Web, :view
  import Scrivener.HTML
  alias EmbedChat.Message

  defp from_id(msg) do
    cond do
      msg.from.uuid ->
        msg.from.uuid
      true ->
        1
    end
  end

  defp from_name(msg) do
    cond do
      user = msg.from_user ->
        EmbedChat.User.name(user)
      msg.from.uuid ->
        msg.from.uuid
      true ->
        "master"
    end
  end

  defp to_id(msg) do
    cond do
      to = msg.to ->
        to.uuid
      true ->
        ""
    end
  end

  def render("message.json", %{message: %Message{} = msg}) do
    %{
      id: msg.id,
      body: msg.body,
      from_id: from_id(msg),
      from_name: from_name(msg),
      to_id: to_id(msg),
      inserted_at: Ecto.DateTime.to_string(msg.inserted_at)
    }
  end

  def sent_by(preload_msg, user) do
    if preload_msg.from_user do
      if preload_msg.from_user.id == user.id do
        "You"
      else
        preload_msg.from_user.email
      end
    else
      preload_msg.from.uuid
    end
  end

  def received_by(preload_msg, user) do
    if preload_msg.to_user do
      if preload_msg.to_user.id == user.id do
        "You"
      else
        preload_msg.to_user.email
      end
    else
      if preload_msg.to do
        preload_msg.to.uuid
      else
        "You"
      end
    end
  end

  @short_message_length 20

  def short_message_body(message) do
    if String.length(message.body) >= @short_message_length do
      String.slice(message.body, 0..@short_message_length) <> ".."
    else
      message.body
    end
  end
end
