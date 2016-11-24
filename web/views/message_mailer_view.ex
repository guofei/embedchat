defmodule EmbedChat.MessageMailerView do
  use EmbedChat.Web, :view

  def render("index.json", %{message_mailers: message_mailers}) do
    %{data: render_many(message_mailers, EmbedChat.MessageMailerView, "message_mailer.json")}
  end

  def render("show.json", %{message_mailer: message_mailer}) do
    %{data: render_one(message_mailer, EmbedChat.MessageMailerView, "message_mailer.json")}
  end

  def render("message_mailer.json", %{message_mailer: message_mailer}) do
    %{id: message_mailer.id,
      address_uuid: message_mailer.address_uuid,
      room_uuid: message_mailer.room_uuid}
  end
end
