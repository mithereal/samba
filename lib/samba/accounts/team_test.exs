defmodule Samba.Accounts.TeamTest do
  use SambaWeb.ConnCase
  require Ash.Query

  describe "Team tests" do
    test "User team can be created" do
      user = create_user()

      # Create a new team for the user
      uuid = Ash.UUIDv7.generate()
      team_count = Ash.count!(Samba.Accounts.Team) + 1
      team_attrs = %{name: "Team #{team_count} #{uuid}", domain: "team_#{team_count}_#{uuid}"}

      {:ok, team} = Ash.create(Samba.Accounts.Team, team_attrs, actor: user)

      # New team should be stored successfully.
      assert Samba.Accounts.Team
             |> Ash.Query.filter(domain == ^team.domain)
             |> Ash.Query.filter(owner_user_id == ^team.owner_user_id)
             |> Ash.exists?(authorize?: false)

      # New team should be set as the current team on the owner
      assert Samba.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(current_team == ^team.domain)
             #  User resource has special policies for authorizations. We are skipping authorization by setting it to false
             |> Ash.exists?(authorize?: false)

      # New team should be added to the teams list of the owner
      assert Samba.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(teams.id == ^team.id)
             |> Ash.exists?(authorize?: false)
    end
  end
end
