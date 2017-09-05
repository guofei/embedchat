defmodule EmbedChatWeb.ProjectController do
  use EmbedChatWeb, :controller

  alias EmbedChat.Project

  plug Guardian.Plug.EnsureAuthenticated, [handler: EmbedChatWeb.AuthErrorHandler]

  def index(conn, _params) do
    projects = Repo.all(user_projects(conn))
    if Enum.count(projects) == 1 do
      project = Enum.fetch!(projects, 0)
      conn |> redirect(to: project_path(conn, :show, project))
    else
      render(conn, "index.html", projects: projects)
    end
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, project_params)

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    projects = user_projects(conn)
    project =
      projects
      |> Repo.get!(id)
      |> Repo.preload([:room])
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: project_path(conn, :index))
  end

  defp user_projects(conn) do
    conn.assigns.current_user |> Ecto.assoc(:projects)
  end
end
