defmodule EmbedChat.MessageView do
  use EmbedChat.Web, :view
  import Scrivener.HTML

  def render("message.json", %{message: msg}) do
    from_id = cond do
      msg.from.uuid ->
        msg.from.uuid
      true ->
        1
    end
    from_name = cond do
      user = msg.from_user ->
        EmbedChat.User.get_name(user)
      msg.from.uuid ->
        msg.from.uuid
      true ->
        "master"
    end
    to_id = cond do
      to = msg.to ->
        to.uuid
      true ->
        ""
    end
    %{
      id: msg.id,
      body: msg.body,
      from_id: from_id,
      from_name: from_name,
      to_id: to_id,
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

  def short_message_body(message) do
    if String.length(message.body) > 21 do
      String.slice(message.body, 0..20) <> ".."
    else
      message.body
    end
  end
end
