defmodule EmbedChatWeb.NewsController do
  use EmbedChatWeb, :controller

  alias EmbedChat.News

  plug Guardian.Plug.EnsureAuthenticated, [key: :admin, handler: EmbedChatWeb.AuthErrorHandler] when action in [:new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    query = from q in News, order_by: [desc: q.id]
    news = Repo.all(query)
    render(conn, "index.html", news: news)
  end

  def new(conn, _params) do
    changeset = News.changeset(%News{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"news" => news_params}) do
    changeset = News.changeset(%News{}, news_params)

    case Repo.insert(changeset) do
      {:ok, _news} ->
        conn
        |> put_flash(:info, "News created successfully.")
        |> redirect(to: news_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    news = Repo.get!(News, id)
    render(conn, "show.html", news: news)
  end

  def edit(conn, %{"id" => id}) do
    news = Repo.get!(News, id)
    changeset = News.changeset(news)
    render(conn, "edit.html", news: news, changeset: changeset)
  end

  def update(conn, %{"id" => id, "news" => news_params}) do
    news = Repo.get!(News, id)
    changeset = News.changeset(news, news_params)

    case Repo.update(changeset) do
      {:ok, news} ->
        conn
        |> put_flash(:info, "News updated successfully.")
        |> redirect(to: news_path(conn, :show, news))
      {:error, changeset} ->
        render(conn, "edit.html", news: news, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news = Repo.get!(News, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(news)

    conn
    |> put_flash(:info, "News deleted successfully.")
    |> redirect(to: news_path(conn, :index))
  end
end
