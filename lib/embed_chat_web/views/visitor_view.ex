defmodule EmbedChatWeb.VisitorView do
  use EmbedChatWeb, :view

  def render("index.json", %{visitors: visitors}) do
    %{data: render_many(visitors, EmbedChatWeb.VisitorView, "visitor.json")}
  end

  def render("show.json", %{visitor: visitor}) do
    %{data: render_one(visitor, EmbedChatWeb.VisitorView, "visitor.json")}
  end

  def render("visitor.json", %{visitor: visitor}) do
    %{id: visitor.id,
      name: visitor.name,
      email: visitor.email,
      note: visitor.note}
  end
end
