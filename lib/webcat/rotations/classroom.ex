defmodule WebCAT.Rotations.Classroom do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}
  alias WebCAT.Repo
  import Ecto.Query

  schema "classrooms" do
    field(:course_code, :string)
    field(:name, :string)
    field(:description, :string)

    has_many(:semesters, WebCAT.Rotations.Semester)
    has_many(:categories, WebCAT.Feedback.Category)
    many_to_many(:users, User, join_through: "user_classrooms")

    timestamps()
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
    |> put_users(Map.get(attrs, "users"))
  end

  defp put_users(%{valid?: true} = changeset, users) when is_list(users) do
    put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^users)))
  end

  defp put_users(changeset, _), do: changeset

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
