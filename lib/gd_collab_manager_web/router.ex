defmodule GdCollabManagerWeb.Router do
  use GdCollabManagerWeb, :router

  import GdCollabManagerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GdCollabManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GdCollabManagerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", GdCollabManagerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gd_collab_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GdCollabManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", GdCollabManagerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{GdCollabManagerWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UserRegistrationLive, :new
      live "/log-in", UserLoginLive, :new
      live "/settings/reset-password", UserForgotPasswordLive, :new
      live "/settings/reset-password/:token", UserResetPasswordLive, :edit
    end

    post "/log-in", UserSessionController, :create
  end

  scope "/", GdCollabManagerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{GdCollabManagerWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm-email/:token", UserSettingsLive, :confirm_email

      live "/my-collabs", Collabs.MyCollabsLive
      live "/my-collabs/new", Collabs.NewCollabLive

      live "/my-collabs/:collab_id", Collabs.CollabInstanceLive

      live "/my-collabs/:collab_id/parts", CollabTools.CollabPartsLive, :index
      live "/my-collabs/:collab_id/parts/new", CollabTools.CollabPartsLive, :new
    end
  end

  scope "/", GdCollabManagerWeb do
    pipe_through [:browser]

    delete "/log-out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{GdCollabManagerWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
