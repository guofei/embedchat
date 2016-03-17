defmodule EmbedChat.MessageView do
  use EmbedChat.Web, :view

  def render("message.json", %{message: msg}) do
    %{
      id: msg.id,
      body: msg.body,
      from_id: msg.from.uuid,
      to_id: msg.to.uuid,
      inserted_at: Ecto.DateTime.to_string(msg.inserted_at)
    }
  end
end
