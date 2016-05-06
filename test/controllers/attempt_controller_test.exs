defmodule EmbedChat.AttemptControllerTest do
  use EmbedChat.ConnCase

  alias EmbedChat.Attempt
  @valid_attrs %{email: "some content", url: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, attempt_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing attempts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, attempt_path(conn, :new)
    assert html_response(conn, 200) =~ "New attempt"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, attempt_path(conn, :create), attempt: @valid_attrs
    assert redirected_to(conn) == attempt_path(conn, :index)
    assert Repo.get_by(Attempt, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, attempt_path(conn, :create), attempt: @invalid_attrs
    assert html_response(conn, 200) =~ "New attempt"
  end

  test "shows chosen resource", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = get conn, attempt_path(conn, :show, attempt)
    assert html_response(conn, 200) =~ "Show attempt"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, attempt_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = get conn, attempt_path(conn, :edit, attempt)
    assert html_response(conn, 200) =~ "Edit attempt"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = put conn, attempt_path(conn, :update, attempt), attempt: @valid_attrs
    assert redirected_to(conn) == attempt_path(conn, :show, attempt)
    assert Repo.get_by(Attempt, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = put conn, attempt_path(conn, :update, attempt), attempt: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit attempt"
  end

  test "deletes chosen resource", %{conn: conn} do
    attempt = Repo.insert! %Attempt{}
    conn = delete conn, attempt_path(conn, :delete, attempt)
    assert redirected_to(conn) == attempt_path(conn, :index)
    refute Repo.get(Attempt, attempt.id)
  end
end
