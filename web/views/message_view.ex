defmodule EmbedChat.MessageView do
  use EmbedChat.Web, :view

  def render("message.json", %{message: msg}) do
    from_name = cond do
      user = msg.from_user ->
        user.name
      true ->
        msg.from.uuid
    end
    %{
      id: msg.id,
      body: msg.body,
      from_id: msg.from.uuid,
      from_name: from_name,
      to_id: msg.to.uuid,
      inserted_at: Ecto.DateTime.to_string(msg.inserted_at)
    }
  end
end
