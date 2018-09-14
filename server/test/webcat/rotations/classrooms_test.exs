defmodule WebCAT.Rotations.ClassroomsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Classrooms

  describe "rotations/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:classroom)
      Factory.insert_list(5, :rotation, classroom: inserted)

      rotations = Classrooms.rotations(inserted.id, limit: 2, offset: 1)
      assert Enum.count(rotations) == 2
    end
  end

  describe "students/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:classroom)
      Factory.insert_list(5, :student, classroom: inserted)

      students = Classrooms.students(inserted.id, limit: 2, offset: 1)
      assert Enum.count(students) == 2
    end
  end

  describe "instructors/2" do
    test "behaves as expected" do
      Factory.insert_list(5, :user)
      inserted = Factory.insert(:classroom, instructors: Factory.insert_list(4, :user))

      instructors = Classrooms.instructors(inserted.id, limit: 2, offset: 1)
      assert Enum.count(instructors) == 2
    end
  end
end