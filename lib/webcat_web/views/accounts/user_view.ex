defmodule WebCATWeb.UserView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "user", collection: "users"

  alias WebCAT.Accounts.User

  def fields,
    do: ~w(email first_name last_name middle_name nickname active inserted_at updated_at)a

  def relationships do
    [
      classrooms: WebCATWeb.ClassroomView,
      semesters: WebCATWeb.SemesterView,
      sections: WebCATWeb.SectionView,
      rotations: WebCATWeb.RotationView,
      rotation_groups: WebCATWeb.RotationGroupView,
      roles: {WebCATWeb.RoleView, :include}
    ]
  end

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
