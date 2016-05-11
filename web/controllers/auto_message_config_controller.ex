defmodule EmbedChat.AutoMessageConfigController do
  use EmbedChat.Web, :controller

  alias EmbedChat.AutoMessageConfig

  plug :scrub_params, "auto_message_config" when action in [:create, :update]

  def index(conn, _params) do
    auto_message_configs = Repo.all(AutoMessageConfig)
    render(conn, "index.html", auto_message_configs: auto_message_configs)
  end

  def new(conn, _params) do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"auto_message_config" => auto_message_config_params}) do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{}, auto_message_config_params)

    case Repo.insert(changeset) do
      {:ok, _auto_message_config} ->
        conn
        |> put_flash(:info, "Auto message config created successfully.")
        |> redirect(to: auto_message_config_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    auto_message_config = Repo.get!(AutoMessageConfig, id)
    render(conn, "show.html", auto_message_config: auto_message_config)
  end

  def edit(conn, %{"id" => id}) do
    auto_message_config = Repo.get!(AutoMessageConfig, id)
    changeset = AutoMessageConfig.changeset(auto_message_config)
    render(conn, "edit.html", auto_message_config: auto_message_config, changeset: changeset)
  end

  def update(conn, %{"id" => id, "auto_message_config" => auto_message_config_params}) do
    auto_message_config = Repo.get!(AutoMessageConfig, id)
    changeset = AutoMessageConfig.changeset(auto_message_config, auto_message_config_params)

    case Repo.update(changeset) do
      {:ok, auto_message_config} ->
        conn
        |> put_flash(:info, "Auto message config updated successfully.")
        |> redirect(to: auto_message_config_path(conn, :show, auto_message_config))
      {:error, changeset} ->
        render(conn, "edit.html", auto_message_config: auto_message_config, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    auto_message_config = Repo.get!(AutoMessageConfig, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(auto_message_config)

    conn
    |> put_flash(:info, "Auto message config deleted successfully.")
    |> redirect(to: auto_message_config_path(conn, :index))
  end
end
