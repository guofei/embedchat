defmodule EmbedChat.VisitorEmailView do
  use EmbedChat.Web, :view

  def from_name(message) do
    if message.from_user do
      message.from_user.name
    else
      "You"
    end
  end

  def to_name(message) do
    if message.to_user do
      message.to_user.name
    else
      "You"
    end
  end
end
