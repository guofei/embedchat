defmodule EmbedChat.VisitorEmail do
  use Bamboo.Phoenix, view: EmbedChat.VisitorEmailView

  @from "Lewini <notification@lewini.com>"

  def send_msgs(visitor, project, messages) do
    base_email
    |> to(visitor.email)
    |> subject("[#{project.name} #{project.domain}] New message")
    |> render(:send_msgs)
  end

  defp base_email do
    new_email
    |> from(@from)
    |> put_text_layout({EmbedChat.LayoutView, "email.text"})
    |> put_html_layout({EmbedChat.LayoutView, "email.html"})
  end
end
