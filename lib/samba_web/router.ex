defmodule SambaWeb.Router do
  use SambaWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html", "md"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SambaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :admin_browser do
    plug :accepts, ["html", "md"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SambaWeb.Layouts, :admin}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/json/open_api",
      default_model_expand_depth: 4

    forward "/", SambaWeb.AshJsonApiRouter
  end

  scope "/", SambaWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      live "/dashboard", DashboardLive
      live "/faq-import", FaqImportLive
      live "/forum-import", PhpbbCrawlerLive

      live "/reports/graphs", Reports.GraphsLive
      live "/reports/summaries", Reports.SummariesLive

      live "/accounts/profile", Accounts.Users.ProfileLive
      live "/accounts/preferences", Accounts.Users.PreferencesLive
      live "/settings", Accounts.Users.SettingsLive
      live "/accounts/teams", Accounts.Teams.TeamsLive
      live "/accounts/teams/new", Accounts.Teams.CreateLive

      live "/accounts/users", Accounts.Users.UsersLive
      live "/accounts/users/invite", Accounts.Users.InviteUserLive
      live "/accounts/users/:user_id/groups", Accounts.Users.UserGroupsLive

      live "/accounts/groups", Accounts.Groups.GroupsLive
      live "/accounts/groups/new", Accounts.Groups.CreateLive
      live "/accounts/groups/edit/:id", Accounts.Groups.EditLive
      live "/accounts/groups/permissions/:group_id", Accounts.Groups.GroupPermissionsLive

      live "/ledger/transfers", Ledger.TransfersLive
      live "/ledger/journal", Ledger.JournalLive
      live "/ledger/chart-of-accounts", Ledger.ChartOfAccountsLive
      live "/ledger/chart-of-accounts/new", Ledger.CreateNewAccountLive

      live "/forums", ForumIndexLive, :index
      live "/forums/rss_feeds", RSSIndexLive, :index
      live "/forum/:id", ForumTopicsLive, :index
      live "/forum/new", NewForumLive, :index
      live "/forum/:forum_id/topic/new", NewTopicLive, :index
      live "/topic/:id", PostsLive, :index
      live "/topic/:id/reply", NewPostLive, :index
      live "/topic/:topic_id/post/new", NewPostLive, :index
      live "/post/:id", PostLive, :index
      live "/post/:id/reply", NewPostLive, :index

      live "/memberlist", MemberListLive, :index
      live "/viewonline", OnlineUsersLive, :index
      live "/profile/:id", UserProfileLive, :index

      live "/settings/categories", Admin.Category.List.Live, :index
      live "/settings/categories/new", Admin.Category.Live.New, :index
      live "/settings/categories/:id/edit", Admin.Category.Live.Edit, :index

      live "/settings/forums", Admin.Forums.List.Live, :index
      live "/settings/forums/new", Admin.New.Forum.Live, :index
      live "/settings/forums/:id/edit", Admin.Edit.Forum.Live, :index
    end
  end

  scope "/", SambaWeb do
    get "/page/:page", PageController, :show

    #    get "/forums/album_search.php", PhpController, :album_search #?search_author=lera.robel
  end

  scope "/api/ckeditor5" do
    # Ensure this pipeline expects JSON
    pipe_through :api

    post "/upload", CKEditor5.Upload.Controller, :upload
  end

  # PHPBB forms
  scope "/", SambaWeb do
    pipe_through :browser

    live "/forums", ForumIndexLive, :index
    live "/memberlist", MemberListLive, :index
    live "/forums/faq", MemberListLive, :index
    live "/forums/rss_feeds", RSSIndexLive, :index
    live "/forum/:id", ForumTopicsLive, :index
    live "/forum/new", NewForumLive, :index
    live "/forum/:forum_id/topic/new", NewTopicLive, :index
    live "/topic/:id", PostsLive, :index
    live "/topic/:id/reply", NewPostLive, :index
    live "/topic/:topic_id/post/new", NewPostLive, :index
    live "/post/:id", PostLive, :index
    live "/post/:id/reply", NewPostLive, :index
    live "/viewonline", OnlineUsersLive, :index
    live "/profile/:id", UserProfileLive, :index

    get "/forums/:forum_id/rss.xml", RSSController, :index
  end

  scope "/", SambaWeb do
    pipe_through :browser

    forward "/llms.txt", SEO.LLMs,
      config: SambaWeb.SEO,
      provider: SambaWeb.LLMsProvider

    live "/", LandingLive, :index

    live "/premium_membership", FaqLive, :index
    live "/faq", FaqLive, :index

    post "/login", AuthController, :login

    auth_routes AuthController, Samba.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # user Impersonations
    get "/accounts/users/impersonate/:user_id", AuthController, :impersonate
    get "/accounts/users/stop/impersonation", AuthController, :stop_impersonating

    #  live "/register", UserRegistrationLive, :new

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{SambaWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    SambaWeb.AuthOverrides,
                    AshAuthentication.Phoenix.Overrides.DaisyUI,
                    SambaWeb.Components.AltchaExtra
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [
                  SambaWeb.AuthOverrides,
                  AshAuthentication.Phoenix.Overrides.Default
                ]

    # Remove this if you do not use the confirmation strategy
    confirm_route Samba.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [SambaWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(Samba.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [SambaWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", SambaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:samba, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SambaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
