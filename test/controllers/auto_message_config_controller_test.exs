defmodule EmbedChatWeb.AutoMessageConfigControllerTest do
  use EmbedChatWeb.ConnCase

  alias EmbedChat.AutoMessageConfig
  @valid_attrs %{message: "some message", current_url: "some content", delay_time: 42, language: "some content", referrer: "some content", visit_view: 3}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = insert_user(username: "test")
    room = insert_room(user)
    conn = guardian_login(conn, user)
    {:ok, conn: conn, user: user, room: room}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, auto_message_config_path(conn, :index)
    assert html_response(conn, 200) =~ "New auto message"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, auto_message_config_path(conn, :new)
    assert html_response(conn, 200) =~ "IF"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, room: room} do
    attrs = Map.put(@valid_attrs, :room_id, room.id)
    conn = post conn, auto_message_config_path(conn, :create), auto_message_config: attrs
    assert redirected_to(conn) == auto_message_config_path(conn, :index)
    assert Repo.get_by(AutoMessageConfig, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, auto_message_config_path(conn, :create), auto_message_config: @invalid_attrs
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    auto_message_config = Repo.insert! %AutoMessageConfig{user_id: user.id}
    conn = get conn, auto_message_config_path(conn, :show, auto_message_config)
    assert html_response(conn, 200) =~ "Then Send Message"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, auto_message_config_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    auto_message_config = Repo.insert! %AutoMessageConfig{user_id: user.id}
    conn = get conn, auto_message_config_path(conn, :edit, auto_message_config)
    assert html_response(conn, 200) =~ "IF"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user, room: room} do
    auto_message_config = Repo.insert! %AutoMessageConfig{user_id: user.id}
    attrs = Map.put(@valid_attrs, :room_id, room.id)
    conn = put conn, auto_message_config_path(conn, :update, auto_message_config), auto_message_config: attrs
    assert redirected_to(conn) == auto_message_config_path(conn, :index)
    assert Repo.get_by(AutoMessageConfig, attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    auto_message_config = Repo.insert! %AutoMessageConfig{user_id: user.id}
    conn = put conn, auto_message_config_path(conn, :update, auto_message_config), auto_message_config: @invalid_attrs
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    auto_message_config = Repo.insert! %AutoMessageConfig{user_id: user.id}
    conn = delete conn, auto_message_config_path(conn, :delete, auto_message_config)
    assert redirected_to(conn) == auto_message_config_path(conn, :index)
    refute Repo.get(AutoMessageConfig, auto_message_config.id)
  end
end
