alias Ecto.Multi
alias Ecto.Changeset
alias WebCAT.Repo
alias WebCAT.Accounts.{User, Notification, Group, PasswordCredential}
alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup, Student}
alias WebCAT.Feedback.{Category, Observation, Feedback, Draft, Comment}

admin_changeset =
  User.changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    active: true
  })

assistant_changeset =
  User.changeset(%User{}, %{
    first_name: "Assistant",
    last_name: "Account",
    active: true
  })

classroom_changeset =
  Classroom.changeset(%Classroom{}, %{
    course_code: "PHY 183",
    name: "Physics for Scientists and Engineers I",
    description: "Default Classroom"
  })

admin_group_changeset = Group.changeset(%Group{}, %{name: "admin"})
assistant_group_changeset = Group.changeset(%Group{}, %{name: "assistant"})

transaction =
  Multi.new()
  |> Multi.insert(:admin_group, admin_group_changeset)
  |> Multi.insert(:assistant_group, assistant_group_changeset)
  |> Multi.run(:admin, fn _repo, %{admin_group: group} ->
    admin_changeset
    |> Changeset.put_assoc(:groups, [group])
    |> Repo.insert()
  end)
  |> Multi.run(:assistant, fn _repo, %{assistant_group: group} ->
    assistant_changeset
    |> Changeset.put_assoc(:groups, [group])
    |> Repo.insert()
  end)
  |> Multi.run(:admin_credentials, fn _repo, %{admin: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      email: "wcat_admin@msu.edu",
      password: "password",
      user_id: user.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:assistant_credentials, fn _repo, %{assistant: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      email: "wcat_assistant@msu.edu",
      password: "password",
      user_id: user.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:classroom, fn _repo, %{admin: admin} ->
    classroom_changeset
    |> Changeset.put_assoc(:users, [admin])
    |> Repo.insert()
  end)
  |> Multi.run(:fall_semester, fn _repo, %{classroom: classroom} ->
    %Semester{}
    |> Semester.changeset(%{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: -3)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 9)),
      name: "Fall",
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:spring_semester, fn _repo, %{classroom: classroom} ->
    %Semester{}
    |> Semester.changeset(%{
      start_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 10)),
      end_date: Timex.to_date(Timex.shift(Timex.now(), weeks: 19)),
      name: "Spring",
      classroom_id: classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_section_1, fn _repo, transaction ->
    %Section{}
    |> Section.changeset(%{
      number: "001",
      description:
        "Example section 001 for Fall Semester #{transaction.fall_semester.start_date.year}",
      semester_id: transaction.fall_semester.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_section_2, fn _repo, transaction ->
    %Section{}
    |> Section.changeset(%{
      number: "002",
      description:
        "Example section 002 for Fall Semester #{transaction.fall_semester.start_date.year}",
      semester_id: transaction.fall_semester.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_rotation_1, fn _repo, transaction ->
    %Rotation{}
    |> Rotation.changeset(%{
      number: 1,
      description:
        "Example rotation for #{transaction.fall_semester.name} semester section #{
          transaction.fall_section_1.number
        }",
      start_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 1)),
      end_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 2)),
      section_id: transaction.fall_section_1.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_rotation_2, fn _repo, transaction ->
    %Rotation{}
    |> Rotation.changeset(%{
      number: 2,
      description:
        "Example rotation for #{transaction.fall_semester.name} semester section #{
          transaction.fall_section_1.number
        }",
      start_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 2)),
      end_date: Timex.to_date(Timex.shift(transaction.fall_semester.start_date, weeks: 3)),
      section_id: transaction.fall_section_1.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_student_1_user, fn _repo, _transaction ->
    %User{}
    |> User.changeset(%{
      first_name: "John",
      last_name: "Doe"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_student_2_user, fn _repo, _transaction ->
    %User{}
    |> User.changeset(%{
      first_name: "Jane",
      last_name: "Doe"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:fall_student_1, fn _repo, transaction ->
    %Student{}
    |> Student.changeset(%{
      email: "john.doe@msu.edu",
      user_id: transaction.fall_student_1_user.id
    })
    |> Changeset.put_assoc(:sections, [transaction.fall_section_1])
    |> Repo.insert()
  end)
  |> Multi.run(:fall_student_2, fn _repo, transaction ->
    %Student{}
    |> Student.changeset(%{
      email: "jane.doe@msu.edu",
      user_id: transaction.fall_student_2_user.id
    })
    |> Changeset.put_assoc(:sections, [transaction.fall_section_1])
    |> Repo.insert()
  end)
  |> Multi.run(:rotation_group_1, fn _repo, transaction ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group 1",
      number: 1,
      rotation_id: transaction.fall_rotation_1.id
    })
    |> Changeset.put_assoc(:students, [transaction.fall_student_1, transaction.fall_student_2])
    |> Changeset.put_assoc(:users, [transaction.assistant])
    |> Repo.insert()
  end)
  |> Multi.run(:rotation_group_2, fn _repo, transaction ->
    %RotationGroup{}
    |> RotationGroup.changeset(%{
      description: "Example rotation group 2",
      number: 2,
      rotation_id: transaction.fall_rotation_1.id
    })
    |> Changeset.put_assoc(:users, [transaction.assistant])
    |> Repo.insert()
  end)
  |> Multi.run(:category_1, fn _repo, transaction ->
    %Category{}
    |> Category.changeset(%{
      name: "Example Category",
      description: "Example Category for Example Classroom",
      classroom_id: transaction.classroom.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:observation_positive, fn _repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example positive observation",
      category_id: transaction.category_1.id,
      rotation_group_id: transaction.rotation_group_1.id,
      type: "positive"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:observation_neutral, fn _repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example neutral observation",
      category_id: transaction.category_1.id,
      rotation_group_id: transaction.rotation_group_1.id,
      type: "neutral"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:observation_negative, fn _repo, transaction ->
    %Observation{}
    |> Observation.changeset(%{
      content: "Example negative observation",
      category_id: transaction.category_1.id,
      rotation_group_id: transaction.rotation_group_1.id,
      type: "negative"
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation_1, fn _repo, transaction ->
    %Feedback{}
    |> Feedback.changeset(%{
      content: "Example explanation 1",
      observation_id: transaction.observation_positive.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation_2, fn _repo, transaction ->
    %Feedback{}
    |> Feedback.changeset(%{
      content: "Example explanation 2",
      observation_id: transaction.observation_positive.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:explanation_3, fn _repo, transaction ->
    %Feedback{}
    |> Feedback.changeset(%{
      content: "Example explanation 3",
      observation_id: transaction.observation_neutral.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:draft_1, fn _repo, transaction ->
    %Draft{}
    |> Draft.changeset(%{
      content: "Example draft",
      status: "approved",
      student_id: transaction.fall_student_1.id,
      rotation_group_id: transaction.rotation_group_1.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:comment_1, fn _repo, transaction ->
    %Comment{}
    |> Comment.changeset(%{
      content: "Looks good! Approving.",
      user_id: transaction.admin.id,
      draft_id: transaction.draft_1.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:comment_2, fn _repo, transaction ->
    %Comment{}
    |> Comment.changeset(%{
      content: "Thanks! 👍",
      user_id: transaction.assistant.id,
      draft_id: transaction.draft_1.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:admin_notification, fn _repo, transaction ->
    %Notification{}
    |> Notification.changeset(%{
      content: "There's a new draft for you to review!",
      draft_id: transaction.draft_1.id,
      user_id: transaction.admin.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:assistant_notification, fn _repo, transaction ->
    %Notification{}
    |> Notification.changeset(%{
      content: "Your draft has been approved!",
      draft_id: transaction.draft_1.id,
      user_id: transaction.assistant.id
    })
    |> Repo.insert()
  end)

{:ok, _} = Repo.transaction(transaction)
