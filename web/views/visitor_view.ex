defmodule EmbedChat.VisitorView do
  use EmbedChat.Web, :view

  def render("index.json", %{visitors: visitors}) do
    %{data: render_many(visitors, EmbedChat.VisitorView, "visitor.json")}
  end

  def render("show.json", %{visitor: visitor}) do
    %{data: render_one(visitor, EmbedChat.VisitorView, "visitor.json")}
  end

  def render("visitor.json", %{visitor: visitor}) do
    %{id: visitor.id,
      name: visitor.name,
      email: visitor.email,
      note: visitor.note}
  end
end
