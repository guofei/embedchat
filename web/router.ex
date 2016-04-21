defmodule EmbedChat.Router do
  use EmbedChat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EmbedChat.Locale, "en"
    plug EmbedChat.Auth, repo: EmbedChat.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmbedChat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/users", UserController, only: [:new, :create, :show]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/rooms", RoomController
  end

  scope "/manage", EmbedChat do
    pipe_through [:browser, :authenticate_user]

    # resources "/chats", VideoController
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmbedChat do
  #   pipe_through :api
  # end
end
