defmodule EmbedChat.TrackController do
  use EmbedChat.Web, :controller

  alias EmbedChat.Address
  alias EmbedChat.Room
  alias EmbedChat.Track

  plug Guardian.Plug.EnsureAuthenticated when action in [:index, :show, :update, :delete]

  def index(conn, _params) do
    tracks = Repo.all(Track)
    render(conn, "index.json", tracks: tracks)
  end

  def create(conn, %{"track" => track_params, "address_uuid" => a_uuid, "room_uuid" => r_uuid}) do
    {:ok, address} = create_or_update_address(a_uuid, r_uuid)
    changeset = Track.changeset(%Track{address_id: address.id}, track_params)

    case Repo.insert(changeset) do
      {:ok, track} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", track_path(conn, :show, track))
        |> render("show.json", track: track)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbedChat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    track = Repo.get!(Track, id)
    render(conn, "show.json", track: track)
  end

  def update(conn, %{"id" => id, "track" => track_params}) do
    track = Repo.get!(Track, id)
    changeset = Track.changeset(track, track_params)

    case Repo.update(changeset) do
      {:ok, track} ->
        render(conn, "show.json", track: track)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbedChat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    track = Repo.get!(Track, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(track)

    send_resp(conn, :no_content, "")
  end

  defp create_or_update_address(address_uuid, room_uuid) do
    address =
      Address
      |> Address.for_room_uuid(room_uuid, address_uuid)
      |> Ecto.Query.limit(1)
      |> Repo.one

    if address do
      address
      |> Address.changeset()
      |> Repo.update(force: true)
    else
      room = Repo.get_by(Room, uuid: room_uuid)
      %Address{}
      |> Address.changeset(%{uuid: address_uuid, room_id: room.id})
      |> Repo.insert
    end
  end
end
