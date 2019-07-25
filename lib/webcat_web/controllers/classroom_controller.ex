defmodule WebCATWeb.ClassroomController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.ClassroomView
  alias WebCAT.Rotations.Classroom
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(course_code name)a,
    filter: ~w()a,
    fields: Classroom.__schema__(:fields),
    include: Classroom.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(ClassroomView)
    |> render("list.json", classrooms: CRUD.list(Classroom, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, classroom} <- CRUD.get(Classroom, id, query) do
      conn
      |> put_status(200)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: classroom)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, classroom} <- CRUD.create(Classroom, params) do
      conn
      |> put_status(201)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: classroom)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create classroom")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Classroom, id, params) do
      conn
      |> put_status(200)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update classroom")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Classroom, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete classroom")}
      {:error, _} = it -> it
    end
  end
end