defmodule WebCAT.Rotations.RotationGroup do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "rotation_groups" do
    field(:number, :integer)
    field(:description, :string)

    belongs_to(:rotation, WebCAT.Rotations.Rotation)

    many_to_many(:users, WebCAT.Accounts.User, join_through: "rotation_group_users", on_replace: :delete)

    timestamps()
  end

  @required ~w(number rotation_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a rotation group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:rotation_id)
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
