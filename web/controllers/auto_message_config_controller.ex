defmodule EmbedChat.AutoMessageConfigController do
  use EmbedChat.Web, :controller

  alias EmbedChat.AutoMessageConfig

  plug :scrub_params, "auto_message_config" when action in [:create, :update]
  plug :authenticate_user

  def index(conn, _params) do
    auto_message_configs = Repo.all user_configs(conn)
    render(conn, "index.html", auto_message_configs: auto_message_configs)
  end

  def new(conn, _params) do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{})
    rooms = Repo.all(user_rooms(conn))
    render(conn, "new.html", changeset: changeset, rooms: rooms)
  end

  def create(conn, %{"auto_message_config" => auto_message_config_params}) do
    changeset =
      conn.assigns.current_user
      |> build_assoc(:auto_message_configs)
      |> AutoMessageConfig.changeset(auto_message_config_params)

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

  def update(conn, %{"id" => id, "auto_message_config" => auto_message_config_params}) do
    auto_message_config = Repo.get!(user_configs(conn), id)
    changeset = AutoMessageConfig.changeset(auto_message_config, auto_message_config_params)

    case Repo.update(changeset) do
      {:ok, auto_message_config} ->
        conn
        |> put_flash(:info, "Auto message config updated successfully.")
        |> redirect(to: auto_message_config_path(conn, :show, auto_message_config))
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

  defp user_configs(conn) do
    conn.assigns.current_user
    |> Ecto.assoc(:auto_message_configs)
  end
end
