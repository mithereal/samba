defmodule SambaWeb.Accounts.Groups.CreateLiveTest do
  use SambaWeb.ConnCase

  describe "Create Group" do
    test "Group can be created", %{conn: conn} do
      user = create_user()

      {:ok, view, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups/new")

      assert html =~
               user.email
               |> to_string()
               |> Phoenix.Naming.humanize()

      # Attempt to create the group

      params = %{name: "Managers", description: "Manager's group"}

      view
      |> form("#user-group-form", form: params)
      |> render_submit()

      # Confirm that the form was create
      require Ash.Query

      assert Samba.Accounts.Group
             |> Ash.Query.filter(name == ^params.name)
             |> Ash.Query.filter(description == ^params.description)
             |> Ash.exists?(actor: user)
    end
  end
end
