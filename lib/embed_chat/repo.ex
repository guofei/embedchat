defmodule EmbedChat.Repo do
  use Ecto.Repo, otp_app: :embed_chat
  use Scrivener, page_size: 20
end
