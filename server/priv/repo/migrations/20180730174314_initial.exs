defmodule WebCAT.Repo.Migrations.Initial do
  use Ecto.Migration

  defmacrop add_req(name, type, options \\ []) do
    # Macro for adding a required (not null) field to the schema
    quote do
      add(unquote(name), unquote(type), unquote(Keyword.put(options, :null, false)))
    end
  end

  def change do
    execute("CREATE EXTENSION pgcrypto;", "DROP EXTENSION pgcrypto;")
    execute("CREATE TYPE user_role AS ENUM ('instructor', 'admin');", "DROP TYPE IF EXISTS user_role;")
    execute("CREATE TYPE draft_status AS ENUM ('review', 'needs_revision', 'approved', 'emailed');", "DROP TYPE IF EXISTS draft_status;")
    execute("CREATE TYPE observation_type AS ENUM ('positive', 'neutral', 'negative');", "DROP TYPE IF EXISTS observation_type;")

    # Accounts

    create table(:users) do
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add_req(:email, :text)
      add_req(:username, :text)
      add_req(:password, :text)
      add(:nickname, :text)
      add(:bio, :text)
      add(:phone, :text)
      add(:city, :text)
      add(:state, :text)
      add(:country, :text)
      add(:birthday, :date)
      add_req(:active, :boolean, default: true)
      add_req(:role, :user_role, default: "instructor")

      timestamps()
    end

    create table(:confirmations) do
      add_req(:token, :text)
      add_req(:user_id, references(:users))
      add_req(:verified, :boolean, default: false)

      timestamps()
    end

    create table(:password_resets) do
      add_req(:token, :text)
      add_req(:user_id, references(:users))

      timestamps()
    end

    # Rotations

    create table(:semesters) do
      add_req(:start_date, :date)
      add_req(:end_date, :date)
      add_req(:title, :text)

      timestamps()
    end

    create table(:classrooms) do
      add_req(:course_code, :text)
      add_req(:section, :text)
      add(:description, :text)
      add_req(:semester_id, references(:semesters))

      timestamps()
    end

    create table(:user_classrooms, primary_key: false) do
      add_req(:user_id, references(:users), primary_key: true)
      add_req(:classroom_id, references(:classrooms), primary_key: true)
    end

    create table(:rotations) do
      add_req(:start_date, :date)
      add_req(:end_date, :date)
      add_req(:classroom_id, references(:classrooms))

      timestamps()
    end

    create table(:students) do
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add(:description, :text)
      add(:email, :text)
      add_req(:classroom_id, references(:classrooms))

      timestamps()
    end

    create table(:rotation_groups) do
      add(:description, :text)
      add_req(:number, :integer)
      add_req(:rotation_id, references(:rotations))
      add_req(:instructor_id, references(:users))

      timestamps()
    end

    create table(:student_groups, primary_key: false) do
      add_req(:rotation_group_id, references(:rotation_groups), primary_key: true)
      add_req(:student_id, references(:students), primary_key: true)
    end

    # Feedback

    create table(:categories) do
      add_req(:name, :text)
      add(:description, :text)
      add(:parent_category_id, references(:categories))

      timestamps()
    end

    create table(:observations) do
      add_req(:content, :text)
      add_req(:type, :observation_type)
      add(:category_id, references(:categories))
      add(:rotation_group_id, references(:rotation_groups))

      timestamps()
    end

    create table(:explanations) do
      add_req(:content, :text)
      add_req(:observation_id, references(:observations))

      timestamps()
    end

    create table(:notes) do
      add_req(:content, :text)
      add(:student_id, references(:students))
      add(:observation_id, references(:observations))
      add(:rotation_group_id, references(:observations))

      timestamps()
    end

    create table(:drafts) do
      add_req(:content, :text)
      add_req(:status, :draft_status)
      add_req(:score, :float)
      add_req(:student_id, references(:students))
      add_req(:rotation_group_id, references(:rotation_groups))

      timestamps()
    end

    create table(:emails) do
      add_req(:status, :text)
      add(:status_message, :text)
      add_req(:draft_id, references(:drafts))

      timestamps()
    end

    create table(:notifications) do
      add_req(:content, :text)
      add_req(:seen, :boolean, default: false)
      add_req(:draft_id, references(:drafts))
      add_req(:user_id, references(:users))

      timestamps()
    end

    create(unique_index(:users, ~w(email)a))
    create(unique_index(:users, ~w(username)a))
    create(unique_index(:confirmations, ~w(token)a))
    create(unique_index(:password_resets, ~w(token)a))
    create(unique_index(:categories, ~w(name)a))
    create(unique_index(:students, ~w(email)a))
  end
end
