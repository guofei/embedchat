defmodule EmbedChat.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:embed_chat, :mailgun_domain),
    key: Application.get_env(:embed_chat, :mailgun_key)

  @from "Lewini <notification@lewini.com>"

  def send_msg_notification(email_address, text) do
    send_email to: email_address,
      from: @from,
      subject: "New message",
      text: text
  end
end
