defmodule SambaWeb.CoreComponents.AshFormTest do
  use SambaWeb.ConnCase

  describe "Ash Form" do
    test "Form can be rendered" do
      _assigns = %{
        id: Ash.UUIDv7.generate(),
        resource: Samba.Members.Member,
        actor: %{},
        tenant: "test",
        authorize?: false
      }
    end
  end
end
