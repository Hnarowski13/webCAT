defmodule WebCATWeb.FeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      Factory.insert_list(3, :feedback)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :index))
        |> json_response(200)

      assert Enum.count(result) >= 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.feedback_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      feedback_id = Factory.insert(:feedback).id

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :show, feedback_id))
        |> json_response(200)

      assert res["id"] == feedback_id
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:feedback)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.feedback_path(conn, :create), data)
        |> json_response(201)

      assert res["name"] == data["name"]
    end

    test "doesn't allow normal users to create feedback", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.feedback_path(conn, :create), Factory.string_params_for(:feedback))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:feedback)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.feedback_path(conn, :update, Factory.insert(:feedback).id), update)
        |> json_response(200)

      assert res["name"] == update["name"]
    end

    test "doesn't allow normal users to update feedback", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:feedback)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.feedback_path(conn, :update, Factory.insert(:feedback).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.feedback_path(conn, :delete, Factory.insert(:feedback).id))
      |> text_response(204)
    end

    test "doesn't allow normal users to delete feedback", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.feedback_path(conn, :delete, Factory.insert(:feedback).id))
      |> json_response(403)
    end
  end

  defp login_admin() do
    user = Factory.insert(:admin)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end

  defp login_user() do
    user = Factory.insert(:user)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end
end