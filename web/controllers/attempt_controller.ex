defmodule EmbedChat.AttemptController do
  use EmbedChat.Web, :controller

  alias EmbedChat.Attempt
  alias EmbedChat.Room

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
        |> put_flash(:info, "Attempt created successfully.")
        |> redirect(to: attempt_path(conn, :show, attempt))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    room = Repo.get!(Room, 1)
    case HTTPoison.get(attempt.url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        render(conn, "show.html", data: body, room: room)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        render(conn, "show.html", data: "Not found :(", room: room)
      {:error, %HTTPoison.Error{reason: reason}} ->
        render(conn, "show.html", data: "Error", room: room)
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
end
