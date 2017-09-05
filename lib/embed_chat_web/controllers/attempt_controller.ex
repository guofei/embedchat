defmodule EmbedChatWeb.AttemptController do
  use EmbedChatWeb, :controller
  alias EmbedChat.Attempt

  plug Guardian.Plug.EnsureAuthenticated, [handler: EmbedChatWeb.AuthErrorHandler] when action in [:index, :update, :edit, :delete]
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
        render(conn, EmbedChatWeb.PageView, "index.html", attempt: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    if conn.scheme == :https && !is_https(attempt.url) do
      redirect(conn, external: to_http(conn, attempt))
    else
      url = get_url(attempt.url)
      case frame(url) do
        {:ok, _} ->
          render(conn, "show.html", url: url, body: false)
        {:error, body} ->
          render(conn, "show.html", url: url, body: body)
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

  defp get_host(url) do
    uri = URI.parse(get_url(url))
    uri.scheme <> "://" <> uri.host
  end

  defp frame(url) do
    new_url = get_url url
    case HTTPoison.get(new_url, [], [follow_redirect: true]) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body}} ->
        if x_frame_options(headers) do
          {:ok, body}
        else
          body =
            body
            |> get_valid_str
            |> replace_url(new_url)
          {:error, get_valid_str(body)}
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404 error"}
      {:error, %HTTPoison.Error{reason: _reason}} ->
        {:error, "error"}
    end
  end

  defp replace_url(str, url) do
    String.replace(str, ~r/(href|src)=(\"|\')(?!http:|https:|\/\/)/, "\\1=\\2#{get_host(url)}/\\3")
  end

  defp get_valid_str(str) do
    if String.valid?(str) do
      str
    else
      str
      |> String.graphemes
      |> Enum.filter(&(String.valid?(&1)))
      |> List.to_string
    end
  end

  defp x_frame_options(headers) do
    if option = List.keyfind(headers, "X-Frame-Options", 0) do
      v =
        option
        |> elem(1)
        |> String.downcase
      if String.contains? v, ["sameorigin", "deny", "allow-from"] do
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
