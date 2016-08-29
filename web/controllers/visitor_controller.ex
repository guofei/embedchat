defmodule EmbedChat.VisitorController do
  use EmbedChat.Web, :controller

  alias EmbedChat.Visitor

  def index(conn, _params) do
    visitors = Repo.all(Visitor)
    render(conn, "index.json", visitors: visitors)
  end

  def create(conn, %{"visitor" => visitor_params}) do
    changeset = Visitor.changeset(%Visitor{}, visitor_params)

    case Repo.insert(changeset) do
      {:ok, visitor} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", visitor_path(conn, :show, visitor))
        |> render("show.json", visitor: visitor)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbedChat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    visitor = Repo.get!(Visitor, id)
    render(conn, "show.json", visitor: visitor)
  end

  def update(conn, %{"id" => id, "visitor" => visitor_params}) do
    visitor = Repo.get!(Visitor, id)
    changeset = Visitor.changeset(visitor, visitor_params)

    case Repo.update(changeset) do
      {:ok, visitor} ->
        render(conn, "show.json", visitor: visitor)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbedChat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    visitor = Repo.get!(Visitor, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(visitor)

    send_resp(conn, :no_content, "")
  end
end
