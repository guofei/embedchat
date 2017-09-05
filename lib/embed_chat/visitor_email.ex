defmodule EmbedChat.VisitorEmail do
  use Bamboo.Phoenix, view: EmbedChatWeb.VisitorEmailView

  @from "Lewini <notification@lewini.com>"

  def send_msgs(visitor, project, messages) do
    base_email()
    |> to(visitor.email)
    |> subject("[#{project.domain}] New message")
    |> render(:send_msgs, messages: messages)
  end

  defp base_email do
    new_email()
    |> from(@from)
    |> put_text_layout({EmbedChatWeb.LayoutView, "email.text"})
    |> put_html_layout({EmbedChatWeb.LayoutView, "email.html"})
  end
end
