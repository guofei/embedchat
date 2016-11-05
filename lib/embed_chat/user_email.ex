defmodule EmbedChat.UserEmail do
  import Bamboo.Email

  @from "Lewini <notification@lewini.com>"

  def send_msg_notification(user, _text) do
    new_email
    |> to(user.email)
    |> from(@from)
    |> subject("[#{user.name} lewini.com] New message")
    |> text_body("There is an unread message. Check it from https://www.lewini.com")
  end
end
