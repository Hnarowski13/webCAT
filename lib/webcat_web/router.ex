defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :not_authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureNotAuthenticated)
  end

  pipeline :authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.LoadResource)
  end

  scope "/login", WebCATWeb do
    pipe_through(:browser)

    get("/", LoginController, :index)
    post("/", LoginController, :login)

    get("/reset", PasswordResetController, :index)
    post("/reset", PasswordResetController, :create)
    get("/reset/:token", PasswordResetController, :reset)
    post("/reset/:token", PasswordResetController, :finish_reset)

    get("/confirm/:token", EmailConfirmationController, :confirm)
  end

  scope "/feedback", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", FeedbackController, :index)
    get("/:rotation_group_id", FeedbackController, :show_rotation_group)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser authenticated)a)

    get("/", IndexController, :index)

    get("/logout", LoginController, :logout)

    forward("/", Dashboard.Router)
  end

end
