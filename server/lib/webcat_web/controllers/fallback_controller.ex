defmodule WebCATWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use WebCATWeb, :controller

  alias WebCATWeb.{ChangesetView, ErrorView}

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(ErrorView, "401.json", %{message: "unauthorized"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render(ErrorView, "403.json", %{message: "forbidden"})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "404.json", %{message: "not found"})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "400.json", %{message: "bad request"})
  end

  def call(conn, {:error, message}) when is_binary(message) or is_map(message) do
    conn
    |> put_status(400)
    |> render(ErrorView, "400.json", %{message: message})
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(500)
    |> render(ErrorView, "500.json", %{})
  end
end