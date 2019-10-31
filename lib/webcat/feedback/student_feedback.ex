defmodule WebCAT.Feedback.StudentFeedback do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebCAT.Feedback.{Feedback, Draft}

  @primary_key false
  schema "student_feedback" do
    field(:id, :integer, auto_generate: true, read_after_writes: true)

    belongs_to(:draft, Draft, primary_key: true)
    belongs_to(:feedback, Feedback, primary_key: true)

    has_one(:observation, through: ~w(feedback observation)a)
    has_one(:category, through: ~w(feedback observation category)a)

    timestamps(type: :utc_datetime)
  end

  @required ~w(draft_id feedback_id)a
  def changeset(student_feedback, attrs \\ %{}) do
    student_feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:draft_id)
    |> foreign_key_constraint(:feedback_id)
  end
end
