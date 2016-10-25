defmodule EmbedChat.Router do
  use EmbedChat.Web, :router

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug EmbedChat.UserPlug
    plug EmbedChat.UserTokenPlug
    plug EmbedChat.UserAddressPlug, repo: EmbedChat.Repo
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EmbedChat.Locale, "en"
    plug EmbedChat.SDK, repo: EmbedChat.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmbedChat do
    pipe_through [:browser, :browser_auth]

    get "/", PageController, :index
    get "/price", PageController, :price
    get "/welcome", PageController, :welcome

    resources "/users", UserController, only: [:index, :new, :create, :show, :edit, :update]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/rooms", RoomController
    resources "/attempts", AttemptController
    resources "/auto_message_configs", AutoMessageConfigController
    resources "/messages", MessageController
  end

  scope "/manage", EmbedChat do
    # resources "/chats", VideoController
  end

  # Other scopes may use custom stacks.
  scope "/api", EmbedChat do
    pipe_through [:api, :api_auth]

    resources "/visitors", VisitorController, except: [:new, :edit]
  end
end
