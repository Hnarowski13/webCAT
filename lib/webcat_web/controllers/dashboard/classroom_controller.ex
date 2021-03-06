defmodule WebCATWeb.ClassroomController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.Classroom
  alias WebCAT.Feedback.Categories

  action_fallback(WebCATWeb.FallbackController)

  @preload [users: [performer: ~w(roles)a], semesters: ~w(sections)a]

  def index(conn, user, _params) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         classrooms <- CRUD.list(Classroom, preload: @preload) do
      render(conn, "index.html", user: user, selected: "classroom", data: classrooms)
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, id, preload: @preload) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        data: Map.replace!(classroom, :categories, Categories.list(id))
      )
    end
  end

  def new(conn, user, _params) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      conn
      |> render("new.html",
        user: user,
        changeset: Classroom.changeset(%Classroom{}),
        selected: "classroom"
      )
    end
  end

  def create(conn, user, %{"classroom" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Classroom, params) do
        {:ok, classroom} ->
          conn
          |> put_flash(:info, "Classroom created!")
          |> redirect(to: Routes.classroom_path(conn, :show, classroom.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom"
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, id, preload: @preload) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Classroom.changeset(classroom)
      )
    end
  end

  def update(conn, user, %{"id" => id, "classroom" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, id, preload: @preload) do
      case CRUD.update(Classroom, classroom, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Classroom updated!")
          |> redirect(to: Routes.classroom_path(conn, :show, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, _} <- CRUD.get(Classroom, id) do
      case CRUD.delete(Classroom, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Classroom deleted successfully")
          |> redirect(to: Routes.classroom_path(conn, :index))

        {:error, _} ->
          conn
          |> put_flash(:error, "Classroom deletion failed")
          |> redirect(to: Routes.classroom_path(conn, :index))
      end
    end
  end
end
