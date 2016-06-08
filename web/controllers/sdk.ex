defmodule EmbedChat.SDK do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    room = EmbedChat.Room |> EmbedChat.Room.first |> repo.one
    if room do
      assign(conn, :chat_id, room.uuid)
    else
      assign(conn, :chat_id, nil)
    end
  end
end
