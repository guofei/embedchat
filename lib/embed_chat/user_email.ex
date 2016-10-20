defmodule EmbedChat.UserEmail do
  import Bamboo.Email

  @from "Lewini <notification@lewini.com>"

  def send_msg_notification(email_address, text) do
    new_email
    |> to(email_address)
    |> from(@from)
    |> subject("New message")
    |> text_body(text)
  end
end
