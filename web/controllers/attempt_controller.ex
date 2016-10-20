defmodule EmbedChat.AttemptController do
  use EmbedChat.Web, :controller
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
      url = get_url(attempt.url)
      room = EmbedChat.Room |> EmbedChat.Room.first |> Repo.one
      if frame_ok?(url) do
        render(conn, "show.html", room: room, url: url)
      else
        conn
        |> put_flash(:info, gettext("Lewini uses iframing to display the demo, but this page doesn't support iframes."))
        |> render("show.html", room: room, url: url)
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

  defp get_url(url) do
    new_url = URI.encode(url)
    if URI.parse(new_url).scheme do
      new_url
    else
      "http://" <> new_url
    end
  end

  defp frame_ok?(url) do
    new_url = get_url url
    case HTTPoison.get(new_url, [], [follow_redirect: true]) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: _body}} ->
        x_frame_options headers
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        false
      {:error, %HTTPoison.Error{reason: _reason}} ->
        false
    end
  end

  defp x_frame_options(headers) do
    if option = List.keyfind(headers, "X-Frame-Options", 0) do
      if elem(option, 1) == "SAMEORIGIN" || elem(option, 1) == "deny" do
        false
      else
        true
      end
    else
      true
    end
  end

  defp is_https(url) do
    uri = URI.parse(get_url(url))
    uri.scheme == "https"
  end

  defp to_http(conn, attempt) do
    path = attempt_path(conn, :show, attempt)
    if conn.port == 80 || conn.port == 443 do
      "http://#{conn.host}#{path}"
    else
      "http://#{conn.host}:#{conn.port}#{path}"
    end
  end
end
