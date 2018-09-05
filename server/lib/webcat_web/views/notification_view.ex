defmodule WebCATWeb.NotificationView do
  @moduledoc """
  Render notifications
  """

  use WebCATWeb, :view

  alias WebCAT.Accounts.Notification

  def render("list.json", %{notifications: notifications}) do
    render_many(notifications, __MODULE__, "notification.json")
  end

  def render("show.json", %{notification: notification}) do
    render_one(notification, __MODULE__, "notification.json")
  end

  def render("notification.json", %{notification: %Notification{} = notification}) do
    notification
    |> Map.from_struct()
    |> Map.take(~w(id content seen draft_id user_id inserted_at updated_at)a)
  end
end
