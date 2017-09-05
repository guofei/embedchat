defmodule EmbedChatWeb.AutoMessageConfigController do
  use EmbedChatWeb, :controller

  alias EmbedChat.AutoMessageConfig

  plug :scrub_params, "auto_message_config" when action in [:create, :update]
  plug Guardian.Plug.EnsureAuthenticated, [handler: EmbedChatWeb.AuthErrorHandler]
  plug :scrub_room_param when action in [:create, :update]

  def index(conn, _params) do
    auto_message_configs =
      conn
      |> user_configs
      |> Ecto.Query.order_by(asc: :id)
      |> Repo.all
    render(conn, "index.html", auto_message_configs: auto_message_configs)
  end

  def new(conn, _params) do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{})
    rooms = Repo.all(user_rooms(conn))
    render(conn, "new.html", changeset: changeset, rooms: rooms)
  end

  def create(conn, %{"auto_message_config" => params}) do
    changeset =
      conn
      |> Guardian.Plug.current_resource
      |> build_assoc(:auto_message_configs)
      |> AutoMessageConfig.changeset(params)

    case Repo.insert(changeset) do
      {:ok, _auto_message_config} ->
        conn
        |> put_flash(:info, "Auto message config created successfully.")
        |> redirect(to: auto_message_config_path(conn, :index))
      {:error, changeset} ->
        rooms = Repo.all(user_rooms(conn))
        render(conn, "new.html", changeset: changeset, rooms: rooms)
    end
  end

  def show(conn, %{"id" => id}) do
    auto_message_config = Repo.get!(user_configs(conn), id)
    render(conn, "show.html", auto_message_config: auto_message_config)
  end

  def edit(conn, %{"id" => id}) do
    auto_message_config = Repo.get!(user_configs(conn), id)
    rooms = Repo.all(user_rooms(conn))
    changeset = AutoMessageConfig.changeset(auto_message_config)
    render(conn, "edit.html", auto_message_config: auto_message_config, changeset: changeset, rooms: rooms)
  end

  def update(conn, %{"id" => id, "auto_message_config" => params}) do
    auto_message_config = Repo.get!(user_configs(conn), id)
    changeset = AutoMessageConfig.changeset(auto_message_config, params)

    case Repo.update(changeset) do
      {:ok, _auto_message_config} ->
        conn
        |> put_flash(:info, "Auto message config updated successfully.")
        |> redirect(to: auto_message_config_path(conn, :index))
      {:error, changeset} ->
        rooms = Repo.all(user_rooms(conn))
        render(conn, "edit.html", auto_message_config: auto_message_config, changeset: changeset, rooms: rooms)
    end
  end

  def delete(conn, %{"id" => id}) do
    auto_message_config = Repo.get!(user_configs(conn), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(auto_message_config)

    conn
    |> put_flash(:info, "Auto message config deleted successfully.")
    |> redirect(to: auto_message_config_path(conn, :index))
  end

  def scrub_room_param(conn, _param) do
    scrub_room(conn, conn.params["auto_message_config"]["room_id"])
  end

  alias EmbedChatWeb.Router.Helpers
  defp scrub_room(conn, room_id) when is_nil(room_id) do
    conn
    |> put_flash(:error, "You must be logged in to access that page")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  defp scrub_room(conn, room_id) do
    room = Repo.get(user_rooms(conn), room_id)
    if room do
      conn
    else
      scrub_room(conn, nil)
    end
  end

  defp user_configs(conn) do
    conn
    |> Guardian.Plug.current_resource
    |> Ecto.assoc(:auto_message_configs)
  end
end
