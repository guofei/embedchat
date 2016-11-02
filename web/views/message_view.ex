defmodule EmbedChat.MessageView do
  use EmbedChat.Web, :view
  import Scrivener.HTML
  alias EmbedChat.Message

  defp from_id(msg) do
    if msg.from.uuid do
      msg.from.uuid
    else
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
    if msg.to do
      msg.to.uuid
    else
      ""
    end
  end

  def render("message.json", %{message: %Message{} = msg}) do
    %{
      id: msg.id,
      type: msg.type,
      body: msg.body,
      from_id: from_id(msg),
      from_name: from_name(msg),
      to_id: to_id(msg),
      inserted_at: Ecto.DateTime.to_string(msg.inserted_at)
    }
  end

  def sent_by(preload_msg, user) do
    cond do
      preload_msg.from_user ->
        if preload_msg.from_user.id == user.id do
          gettext "You"
        else
          preload_msg.from_user.email
        end
      preload_msg.from_visitor ->
        if preload_msg.from_visitor.name do
          preload_msg.from_visitor.name
        else
          preload_msg.from_visitor.email
        end
      true ->
        preload_msg.from.uuid
    end
  end

  def received_by(preload_msg, user) do
    cond do
      preload_msg.to_user ->
        if preload_msg.to_user.id == user.id do
          gettext "You"
        else
          preload_msg.to_user.email
        end
      preload_msg.to_visitor ->
        if preload_msg.to_visitor.name do
          preload_msg.to_visitor.name
        else
          preload_msg.to_visitor.email
        end
      preload_msg.to ->
        preload_msg.to.uuid
      true ->
        gettext "You"
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
