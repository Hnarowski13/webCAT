defmodule WebCAT.Repo.Migrations.AddStudentExplanation do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    create table(:student_explanations, primary_key: false) do
      add_req(:explanation_id, references(:explanations, on_delete: :delete_all),
        primary_key: true
      )

      add_req(:feedback_id, :integer, primary_key: true)
      add_req(:rotation_group_id, :integer, primary_key: true)
      add_req(:user_id, :integer, primary_key: true)

      timestamps(type: :timestamptz)
    end

    execute(
      """
      ALTER TABLE student_explanations ADD CONSTRAINT fk_student_feedback FOREIGN KEY (user_id, rotation_group_id, feedback_id) REFERENCES student_feedback (user_id, rotation_group_id, feedback_id) ON DELETE CASCADE;
      """,
      """
      ALTER TABLE student_explanations DROP CONSTRAINT fk_student_feedback;
      """
    )
  end
end
