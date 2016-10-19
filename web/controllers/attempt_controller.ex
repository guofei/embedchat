defmodule EmbedChat.AttemptController do
  use EmbedChat.Web, :controller
  use Hound.Helpers
  alias EmbedChat.Attempt

  plug :authenticate_user when action in [:index, :update, :edit, :delete]
  plug :scrub_params, "attempt" when action in [:create, :update]

  def index(conn, _params) do
    attempts = Repo.all(Attempt)
    render(conn, "index.html", attempts: attempts)
  end

  def new(conn, _params) do
    changeset = Attempt.changeset(%Attempt{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"attempt" => attempt_params}) do
    changeset = Attempt.changeset(%Attempt{}, attempt_params)

    case Repo.insert(changeset) do
      {:ok, attempt} ->
        conn
        |> put_flash(:info, "waiting...")
        |> redirect(to: attempt_path(conn, :show, attempt))
      {:error, changeset} ->
        render(conn, EmbedChat.PageView, "index.html", attempt: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    if conn.scheme == :https && !is_https(attempt.url) do
      redirect(conn, external: to_http(conn, attempt))
    else
      room = EmbedChat.Room |> EmbedChat.Room.first |> Repo.one
      source = get_source(attempt.url)
      if source == "<html><head></head><body></body></html>" do
        render(conn, "show.html", data: "Not found :( <br> url: #{attempt.url}", room: room)
      else
        render(conn, "show.html", data: source, room: room)
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    changeset = Attempt.changeset(attempt)
    render(conn, "edit.html", attempt: attempt, changeset: changeset)
  end

  def update(conn, %{"id" => id, "attempt" => attempt_params}) do
    attempt = Repo.get!(Attempt, id)
    changeset = Attempt.changeset(attempt, attempt_params)

    case Repo.update(changeset) do
      {:ok, attempt} ->
        conn
        |> put_flash(:info, "Attempt updated successfully.")
        |> redirect(to: attempt_path(conn, :show, attempt))
      {:error, changeset} ->
        render(conn, "edit.html", attempt: attempt, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(attempt)

    conn
    |> put_flash(:info, "Attempt deleted successfully.")
    |> redirect(to: attempt_path(conn, :index))
  end

  defp get_source(url) do
    Hound.start_session
    url
    |> String.trim
    |> get_url
    |> navigate_to
    source = page_source
    Hound.end_session
    String.replace(source, ~r/(href|src)=(\"|\')(?!http:|https:|\/\/)/, "\\1=\\2#{get_host(url)}/\\3")
  end

  defp get_url(url) do
    new_url = URI.encode(url)
    if URI.parse(new_url).scheme do
      new_url
    else
      "http://" <> new_url
    end
  end

  defp get_host(url) do
    uri = URI.parse(get_url(url))
    uri.scheme <> "://" <> uri.host
  end

  defp is_https(url) do
    uri = URI.parse(get_url(url))
    uri.scheme == :https
  end

  defp to_http(conn, attempt) do
    path = attempt_path(conn, :show, attempt)
    if conn.port == 80 do
      "http://#{conn.host}#{path}"
    else
      "http://#{conn.host}:#{conn.port}#{path}"
    end
  end
end
