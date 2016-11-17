defmodule EmbedChat.AddressView do
  use EmbedChat.Web, :view
  import Scrivener.HTML

  def visitor_name(address) do
    if address.visitor do
      address.visitor.name
    else
      ""
    end
  end

  def visitor_email(address) do
    if address.visitor do
      address.visitor.email
    else
      ""
    end
  end

  def visitor_note(address) do
    if address.visitor do
      address.visitor.note
    else
      ""
    end
  end
end
