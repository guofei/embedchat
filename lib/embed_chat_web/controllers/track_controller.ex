defmodule EmbedChatWeb.TrackController do
  use EmbedChatWeb, :controller

  alias EmbedChat.Address
  alias EmbedChat.AutoMessageConfig
  alias EmbedChatWeb.Chat
  alias EmbedChat.Room
  alias EmbedChat.Track
  alias EmbedChatWeb.TrackView
  alias Phoenix.View

  plug Guardian.Plug.EnsureAuthenticated when action in [:index, :show, :update, :delete]

  def index(conn, _params) do
    tracks = Repo.all(Track)
    render(conn, "index.json", tracks: tracks)
  end

  def create(conn, %{"track" => track_params, "address_uuid" => a_uuid, "room_uuid" => r_uuid}) do
    ip =
      conn.remote_ip
      |> Tuple.to_list
      |> Enum.join(".")
    room = Repo.get_by(Room, uuid: r_uuid)
    {:ok, address} = create_or_update_address(a_uuid, room)
    changeset =
      address
      |> Ecto.build_assoc(:tracks, ip: ip)
      |> Track.changeset(track_params)

    case Repo.insert(changeset) do
      {:ok, track} ->
        resp =
          TrackView
          |> View.render("track.json", track: track)
          |> Map.merge(%{uid: a_uuid})
        EmbedChatWeb.Endpoint.broadcast "rooms:#{r_uuid}", "track", resp
        auto_message(a_uuid, room, track)
        conn
        |> put_status(:created)
        |> put_resp_header("location", track_path(conn, :show, track))
        |> render("show.json", track: track)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbedChatWeb.ChangesetView, "error.json", changeset: changeset)
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
        |> render(EmbedChatWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    track = Repo.get!(Track, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(track)

    send_resp(conn, :no_content, "")
  end

  defp auto_message(to_uuid, room, %Track{} = track) do
    all_messages =
      AutoMessageConfig
      |> AutoMessageConfig.all_configs(room.id)
      |> Repo.all
    messages = EmbedChat.AutoMessageConfig.match(all_messages, track)
    Enum.each(messages, fn (msg) ->
      resp =
        msg
        |> message_param(room, to_uuid)
        |> Chat.operator_to_visitor
        |> Chat.response
      case resp do
        {:ok, resp} ->
          EmbedChatWeb.Endpoint.broadcast "rooms:#{room.uuid}", "new_message", resp
        {:error, _} ->
          nil
      end
    end)
  end

  defp message_param(msg, room, to_uuid) do
    %Chat{
      room_id: room.id,
      to_uid: to_uuid,
      text: msg.message
    }
  end

  defp create_or_update_address(address_uuid, room) do
    address =
      Address
      |> Ecto.Query.where([a], a.uuid == ^address_uuid and a.room_id == ^room.id)
      |> Ecto.Query.limit(1)
      |> Repo.one

    if address do
      address
      |> Address.changeset()
      |> Repo.update(force: true)
    else
      %Address{}
      |> Address.changeset(%{uuid: address_uuid, room_id: room.id})
      |> Repo.insert
    end
  end
end
