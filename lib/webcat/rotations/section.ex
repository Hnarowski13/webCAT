defmodule WebCAT.Rotations.Section do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "sections" do
    field(:number, :string)
    field(:description, :string)

    belongs_to(:semester, WebCAT.Rotations.Semester)
    has_many(:rotations, WebCAT.Rotations.Rotation)
    many_to_many(:users, User, join_through: "section_users", on_replace: :delete)

    timestamps()
  end

  @required ~w(number semester_id)a
  @optional ~w(description)a

  def changeset(section, attrs \\ %{}) do
    section
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:semester_id)
    |> put_users(Map.get(attrs, "users"))
  end

  defp put_users(%{valid?: true} = changeset, users) when is_list(users) do
    ids =
      users
      |> Enum.map(fn user ->
        cond do
          is_map(user) ->
            Map.get(user, "id")

          is_integer(user) ->
            user

          true ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^ids)))
  end

  defp put_users(changeset, _), do: changeset
end
