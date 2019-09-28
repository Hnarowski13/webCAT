defmodule WebCATWeb.ObservationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      category = Factory.insert(:category)
      Factory.insert_list(3, :observation, category: category)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :index, category_id: category.id))
        |> json_response(200)

      assert Enum.count(result) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.observation_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      observation= Factory.insert(:observation)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :show, observation.id))
        |> json_response(200)

      assert res["data"]["id"] == to_string(observation.id)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:observation)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.observation_path(conn, :create), data)
        |> json_response(201)

      assert res["data"]["attributes"]["content"] == data["content"]
    end

    test "doesn't allow normal users to create observations", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.observation_path(conn, :create), Factory.string_params_for(:observation))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:observation)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.observation_path(conn, :update, Factory.insert(:observation).id), update)
        |> json_response(200)

      assert res["data"]["attributes"]["content"] == update["content"]
    end

    test "doesn't allow normal users to update observations", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:observation)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.observation_path(conn, :update, Factory.insert(:observation).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.observation_path(conn, :delete, Factory.insert(:observation).id))
      |> json_response(200)
    end

    test "doesn't allow normal users to delete observations", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.observation_path(conn, :delete, Factory.insert(:observation).id))
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
