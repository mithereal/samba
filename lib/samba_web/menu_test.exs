defmodule SambaWeb.MenuTest do
  use SambaWeb.ConnCase

  describe "Menu module" do
    test "left_menu/0 module returns an array" do
      user = create_user()
      assert is_list(SambaWeb.Menu.left_menu(user))
    end
  end
end
