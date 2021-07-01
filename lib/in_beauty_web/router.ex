defmodule InBeautyWeb.Router do
  use InBeautyWeb, :router

  import InBeautyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {InBeautyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug InBeautyWeb.Plugs.SessionPlug
    plug InBeautyWeb.Plugs.CurrentCartIdPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InBeautyWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", InBeautyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: InBeautyWeb.Telemetry
    end
  end

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    # If using Plug.Router, make sure to add the `to`
    # forward "/sent_emails", to: Bamboo.SentEmailViewerPlug
  end

  ## Authentication routes
  scope "/", InBeautyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    live "/authorization", UserLive.Authorization,                        :create
    post "/log_in", UserSessionController,                                :create

    pipe_through [InBeautyWeb.Plugs.UserByResetPasswordToken]
    live "/reset_password/:token", UserLive.ResetPassword,                :reset_password
  end

  scope "/", InBeautyWeb do
    pipe_through [:browser, :require_authenticated_user]
    live "/profile/settings", UserLive.Profile.Settings,                  :settings
    live "/profile", UserLive.Profile,                                    :profile
    # get "/users/settings", UserSettingsController, :edit
    # put "/users/settings", UserSettingsController, :update
    get "/profile/settings/confirm_email/:token", UserSettingsController, :confirm_email
    delete "/users/log_out", UserSessionController,                       :delete
  end

  scope "/admin", InBeautyWeb do
    pipe_through [:browser, :require_admin_user]
    live "/users", UserLive.Index,                                        :index
    live "/users/:id/edit", UserLive.Index,                               :update
    live "/products", ProductLive.AdminIndex,                             :index
    live "/products/filters", ProductLive.AdminIndex,                     :filters
    live "/products/new", ProductLive.AdminNew,                           :create
    live "/products/:id/edit", ProductLive.AdminEdit,                     :edit
    live "/carts", CartLive.Index,                                        :index
    live "/carts/filters", CartLive.Index,                                :filters
  end

  scope "/", InBeautyWeb do
    pipe_through [:browser]
    live "/products", ProductLive.Index,                                  :index
    live "/products/filters", ProductLive.Index,                          :filters
    live "/products/:id", ProductLive.Show,                               :show
    live "/products/:id/image/:path", ProductLive.Show,                   :image
    live "/products/:id/image/:path", ProductLive.Image,                  :image
    live "/cart", CartLive.Show,                                          :show
    #TODO check user confurmations logic
    get "/users/confirm", UserConfirmationController,                     :new
    post "/users/confirm", UserConfirmationController,                    :create
    get "/users/confirm/:token", UserConfirmationController,              :confirm
    live "/orders/new", OrderLive.New,                                    :new
    live "/orders/new/map", OrderLive.New,                                :map
    live "/orders/new/search", OrderLive.New,                             :search
    live "/orders/new/courier", OrderLive.New,                            :courier
    live "/orders/step_2/:id", OrderLive.SecondStep,                      :step_2
  end
end
