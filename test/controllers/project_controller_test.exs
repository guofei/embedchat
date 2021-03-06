defmodule EmbedChatWeb.ProjectControllerTest do
  use EmbedChatWeb.ConnCase

  alias EmbedChat.Project
  @valid_attrs %{domain: "some content", name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = insert_user(username: "test")
    conn = guardian_login(conn, user)
    {:ok, conn: conn, user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, project_path(conn, :index)
    assert html_response(conn, 200) =~ "Project Name"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, project_path(conn, :new)
    assert html_response(conn, 200) =~ "Name"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: @valid_attrs
    assert redirected_to(conn) == project_path(conn, :index)
    assert Repo.get_by(Project, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: @invalid_attrs
    assert html_response(conn, 200) =~ "Submit"
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    project = insert_project user, %Project{}
    conn = get conn, project_path(conn, :show, project)
    assert html_response(conn, 200) =~ "Name"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, project_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = get conn, project_path(conn, :edit, project)
    assert html_response(conn, 200) =~ "Submit"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = put conn, project_path(conn, :update, project), project: @valid_attrs
    assert redirected_to(conn) == project_path(conn, :show, project)
    assert Repo.get_by(Project, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = put conn, project_path(conn, :update, project), project: @invalid_attrs
    assert html_response(conn, 200) =~ "Submit"
  end

  test "deletes chosen resource", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = delete conn, project_path(conn, :delete, project)
    assert redirected_to(conn) == project_path(conn, :index)
    refute Repo.get(Project, project.id)
  end

  defp insert_project(user, attrs) do
    {_, project} = Repo.insert(attrs)
    Repo.insert!(%EmbedChat.UserProject{user_id: user.id, project_id: project.id})
    Repo.insert!(%EmbedChat.Room{uuid: uuid(), project_id: project.id})
    project
  end
end
