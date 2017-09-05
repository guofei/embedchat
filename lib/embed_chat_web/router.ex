defmodule EmbedChatWeb.Router do
  use EmbedChatWeb, :router

  if Mix.env == :pod do
    use Plug.ErrorHandler
    use Sentry.Plug
  end

  # This plug will look for a Guardian token in the session in the default location
  # Then it will attempt to load the resource found in the JWT.
  # If it doesn't find a JWT in the default location it doesn't do anything
  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug EmbedChatWeb.UserPlug
    plug EmbedChatWeb.UserTokenPlug
    plug EmbedChatWeb.UserAddressPlug, repo: EmbedChat.Repo
  end

  # This pipeline is created for use within the admin namespace.
  # It looks for a valid token in the session - but in the 'admin' location of guardian
  # This keeps the session credentials seperate for the main site, and the admin site
  # It's very possible that a user is logged into the main site but not the admin
  # or it could be that you're logged into both.
  # This does not conflict with the browser_auth pipeline.
  # If it doesn't find a JWT in the location it doesn't do anything
  pipeline :admin_browser_auth do
    plug Guardian.Plug.VerifySession, key: :admin
    plug Guardian.Plug.LoadResource, key: :admin
    plug EmbedChatWeb.AdminPlug
  end

  # We need this pipeline to load the token when we're impersonating.
  # We don't want to load the resource though, just verify the token
  pipeline :impersonation_browser_auth do
    plug Guardian.Plug.VerifySession, key: :admin
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
    plug EmbedChatWeb.Locale, "en"
    plug EmbedChatWeb.SDK, repo: EmbedChat.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmbedChatWeb do
    pipe_through [:browser, :browser_auth, :impersonation_browser_auth]

    get "/", PageController, :index
    get "/price", PageController, :price
    get "/welcome", PageController, :welcome

    resources "/users", UserController, only: [:index, :new, :create, :show, :edit, :update]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/rooms", RoomController
    resources "/attempts", AttemptController
    resources "/auto_message_configs", AutoMessageConfigController
    resources "/messages", MessageController
    resources "/projects", ProjectController
    resources "/addresses", AddressController, only: [:show, :index]
    resources "/news", NewsController
  end

  pipeline :admin_layout do
    plug :put_layout, {EmbedChatWeb.LayoutView, :admin}
  end

  # This scope is intended for admin users.
  # Normal users can only go to the login page
  scope "/admin", EmbedChat.Admin, as: :admin do
    pipe_through [:browser, :admin_browser_auth, :admin_layout]

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    post "/impersonate/:user_id", SessionController, :impersonate, as: :impersonation
    delete "/impersonate", SessionController, :stop_impersonating
    resources "/users", UserController
  end

  scope "/manage", EmbedChatWeb do
    # resources "/chats", VideoController
  end

  # Other scopes may use custom stacks.
  scope "/api", EmbedChatWeb do
    pipe_through [:api, :api_auth]

    resources "/visitors", VisitorController, except: [:new, :edit]
    resources "/message_mailers", MessageMailerController, only: [:create]
    resources "/tracks", TrackController, except: [:new, :edit]
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end
end
