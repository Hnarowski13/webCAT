defmodule WebCAT.Rotations.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "classrooms" do
    field(:course_code, :string)
    field(:name, :string)
    field(:description, :string)

    has_many(:semesters, WebCAT.Rotations.Semester)
    has_many(:categories, WebCAT.Feedback.Category)
    many_to_many(:users, User, join_through: "classroom_users", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(course_code name)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a classroom
  """
  def changeset(classroom, attrs \\ %{}) do
    classroom
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:course_code, name: :classrooms_course_code_index)
    |> put_users(Map.get(attrs, "users"))
  end

  defp put_users(%{valid?: true} = changeset, users) when is_list(users) do
    ids =
      users
      |> Enum.map(fn user ->
        case user do
          %{id: id} ->
            id

          id when is_integer(id) ->
            id

          id when is_binary(id) ->
            String.to_integer(id)

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    changeset
    |> Map.put(:data, Map.put(changeset.data, :users, []))
    |> put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^ids)))
  end

  defp put_users(changeset, _), do: changeset
end
