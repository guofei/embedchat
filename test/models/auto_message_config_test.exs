defmodule EmbedChat.AutoMessageConfigTest do
  use EmbedChat.ModelCase

  alias EmbedChat.AutoMessageConfig

  @valid_attrs %{
    message: "some message",
    delay_time: 42,
    current_url: "rooms",
    current_url_pattern: "=",
    language: "en",
    language_pattern: "=",
    referrer: "",
    referrer_pattern: "=",
    visit_view: 3,
    visit_view_pattern: nil,
    single_page_view: 4,
    single_page_view_pattern: "=",
    total_page_view: 5,
    total_page_view_pattern: ">",
    room_id: 1
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AutoMessageConfig.changeset(%AutoMessageConfig{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "match current status" do
    model = %{@valid_attrs | current_url_pattern: "~="}
    assert EmbedChat.AutoMessageConfig.match(model, %{current_url: "rooms/1", referrer: "", language: "en", visit_view: 3, single_page_view: 4, total_page_view: 6})
  end

  test "match current url" do
    assert EmbedChat.AutoMessageConfig.match(@valid_attrs, %{current_url: "http://rooms", referrer: "", language: "English", visit_view: nil, single_page_view: 4, total_page_view: 6})
  end
end
