defmodule EmbedChatWeb.TrackControllerTest do
  use EmbedChatWeb.ConnCase

  alias EmbedChat.Track
  @valid_attrs %{agent: "some content", current_url: "some content", language: "some content", location: "some content", referrer: "some content", screen_height: 42, screen_width: 42, single_page_view: 42, total_page_view: 42, visit_view: 42}

  setup %{conn: conn} do
    user = insert_user(username: "test")
    room = insert_room(user, %{})
    address = insert_address(user, room)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, room: room, address: address}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, track_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    track = Repo.insert! %Track{}
    conn = get conn, track_path(conn, :show, track)
    assert json_response(conn, 200)["data"] == %{"id" => track.id,
      "agent" => track.agent,
      "current_url" => track.current_url,
      "referrer" => track.referrer,
      "screen_width" => track.screen_width,
      "screen_height" => track.screen_height,
      "language" => track.language,
      "visit_view" => track.visit_view,
      "single_page_view" => track.single_page_view,
      "total_page_view" => track.total_page_view,
      "location" => track.location,
      "ip" => track.ip,
      "address_id" => track.address_id,
      "inserted_at" => NaiveDateTime.to_iso8601(track.inserted_at)}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, track_path(conn, :show, -1)
    end
  end

  test "creates with address and renders resource when data is valid", %{conn: conn, room: room} do
    conn = post conn, track_path(conn, :create), track: @valid_attrs, address_uuid: "7488a646-e31f-11e4-aace-600308960662", room_uuid: room.uuid
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Track, @valid_attrs)
  end

  test "creates and renders resource when data is valid", %{conn: conn, room: room, address: address} do
    conn = post conn, track_path(conn, :create), track: @valid_attrs, address_uuid: address.uuid, room_uuid: room.uuid
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Track, @valid_attrs)
  end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, track_path(conn, :create), track: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    track = Repo.insert! %Track{}
    conn = put conn, track_path(conn, :update, track), track: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Track, @valid_attrs)
  end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   track = Repo.insert! %Track{}
  #   conn = put conn, track_path(conn, :update, track), track: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "deletes chosen resource", %{conn: conn} do
    track = Repo.insert! %Track{}
    conn = delete conn, track_path(conn, :delete, track)
    assert response(conn, 204)
    refute Repo.get(Track, track.id)
  end
end
