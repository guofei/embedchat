defmodule EmbedChat.RoomControllerTest do
  use EmbedChat.ConnCase
  alias EmbedChat.Room

  @valid_attrs %{}
  # @invalid_attrs %{}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on actions except show", %{conn: conn} do
    Enum.each([
      get(conn, room_path(conn, :new)),
      get(conn, room_path(conn, :index)),
      get(conn, room_path(conn, :edit, "123")),
      put(conn, room_path(conn, :update, "123"), room: @valid_attrs),
      post(conn, room_path(conn, :create), room: @valid_attrs),
      delete(conn, room_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users",
  %{user: owner, conn: conn} do
    room = insert_room(owner, @valid_attrs)
    non_owner = insert_user(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, room_path(conn, :edit, room))
    end
    assert_error_sent :not_found, fn ->
      put(conn, room_path(conn, :update, room), room: @valid_attrs)
    end
    assert_error_sent :not_found, fn ->
      delete(conn, room_path(conn, :delete, room))
    end
  end

  @tag login_as: "max"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, room_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing rooms"
  end

  @tag login_as: "max"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, room_path(conn, :new)
    assert html_response(conn, 200) =~ "New room"
  end

  @tag login_as: "max"
  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = post conn, room_path(conn, :create), room: @valid_attrs
    assert redirected_to(conn) == room_path(conn, :index)
    assert Repo.get_by(Room, @valid_attrs).user_id == user.id
  end

  # @tag login_as: "max"
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, room_path(conn, :create), room: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New room"
  # end

  test "shows chosen resource", %{conn: conn} do
    user = insert_user()
    room = insert_room user, @valid_attrs
    conn = get conn, room_path(conn, :show, room)
    assert html_response(conn, 200) =~ "Show room"
  end

  @tag login_as: "max"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, room_path(conn, :show, -1)
    end
  end

  @tag login_as: "max"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    room = insert_room user, @valid_attrs
    conn = get conn, room_path(conn, :edit, room)
    assert html_response(conn, 200) =~ "Edit room"
  end

  @tag login_as: "max"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    room = insert_room user, @valid_attrs
    conn = put conn, room_path(conn, :update, room), room: @valid_attrs
    assert redirected_to(conn) == room_path(conn, :show, room)
    assert Repo.get_by(Room, @valid_attrs)
  end

  # @tag login_as: "max"
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   room = Repo.insert! Ecto.build_assoc(conn.assigns.current_user, :rooms)
  #   conn = put conn, room_path(conn, :update, room), room: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit room"
  # end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    room = insert_room user, @valid_attrs
    conn = delete conn, room_path(conn, :delete, room)
    assert redirected_to(conn) == room_path(conn, :index)
    refute Repo.get(Room, room.id)
  end
end
