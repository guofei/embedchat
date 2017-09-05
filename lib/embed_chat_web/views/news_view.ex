defmodule EmbedChatWeb.NewsView do
  use EmbedChatWeb, :view

  def locale_content(news) do
    case Gettext.get_locale(EmbedChatWeb.Gettext) do
      "en" -> news.content_en
      "ja" -> news.content_ja
      "zh" -> news.content_zh
      _ -> news.content_en
    end
  end
end
