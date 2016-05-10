defmodule EmbedChat.AttemptControllerTest do
  use EmbedChat.ConnCase

  alias EmbedChat.Attempt
  @valid_attrs %{email: "some content", url: "http://google.com"}
  @invalid_attrs %{}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @tag login_as: "user"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, attempt_path(conn, :index)
    assert html_response(conn, 200) =~ "New attempt"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, attempt_path(conn, :new)
    assert html_response(conn, 200)
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, attempt_path(conn, :create), attempt: @valid_attrs
    attempt = Repo.get_by(Attempt, @valid_attrs)
    assert attempt
    assert redirected_to(conn) == attempt_path(conn, :show, attempt)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, attempt_path(conn, :create), attempt: @invalid_attrs
    assert html_response(conn, 200) =~ "error"
  end

  test "shows chosen resource", %{conn: conn} do
    TODO
    # attempt = Repo.insert! %Attempt{}
    # conn = get conn, attempt_path(conn, :show, attempt)
    # assert html_response(conn, 200) =~ "Show attempt"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, attempt_path(conn, :show, -1)
    end
  end

  @tag login_as: "user"
  test "renders form for editing chosen resource", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = get conn, attempt_path(conn, :edit, attempt)
    assert html_response(conn, 200) =~ "Edit attempt"
  end

  @tag login_as: "user"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = put conn, attempt_path(conn, :update, attempt), attempt: @valid_attrs
    assert redirected_to(conn) == attempt_path(conn, :show, attempt)
    assert Repo.get_by(Attempt, @valid_attrs)
  end

  @tag login_as: "user"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = put conn, attempt_path(conn, :update, attempt), attempt: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit attempt"
  end

  @tag login_as: "user"
  test "deletes chosen resource", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = delete conn, attempt_path(conn, :delete, attempt)
    assert redirected_to(conn) == attempt_path(conn, :index)
    refute Repo.get(Attempt, attempt.id)
  end
end
