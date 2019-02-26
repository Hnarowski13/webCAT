alias Ecto.Multi
alias WebCAT.Repo
alias WebCAT.Accounts.{User, PasswordCredential}

alias Terminator.{Ability, Performer, Role}

admin_changeset =
  User.changeset(%User{}, %{
    first_name: "Admin",
    last_name: "Account",
    email: "wcat_admin@msu.edu",
    active: true
  })

admin_password =
  :crypto.strong_rand_bytes(4)
  |> Base.encode32()
  |> String.downcase()

{:ok, _} =
  Multi.new()
  |> Multi.insert(:admin, admin_changeset)
  |> Multi.run(:admin_credentials, fn _repo, %{admin: user} ->
    %PasswordCredential{}
    |> PasswordCredential.changeset(%{
      password: admin_password,
      user_id: user.id
    })
    |> Repo.insert()
  end)
  |> Multi.run(:granted, fn _repo, transaction ->
    Performer.grant(transaction.admin.performer, Map.get(transaction, {:role, "admin"}))

    {:ok, nil}
  end)
  |> Repo.transaction(transaction)

IO.puts("""
*****************************
* Email: wcat_admin@msu.edu *
* Password: #{admin_password}        *
*****************************
""")
