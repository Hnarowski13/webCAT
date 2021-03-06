defmodule WebCAT.Feedback.Observation do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}

  schema "observations" do
    field(:content, :string)
    field(:type, :string)

    belongs_to(:category, WebCAT.Feedback.Category)

    has_many(:feedback, WebCAT.Feedback.Feedback)

    timestamps()
  end

  @required ~w(content type category_id)a

  @doc """
  Create a changeset for an observation
  """
  def changeset(observation, attrs \\ %{}) do
    observation
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_inclusion(:type, ~w(positive neutral negative))
    |> foreign_key_constraint(:category_id)
  end
end
