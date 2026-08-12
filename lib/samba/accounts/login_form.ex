defmodule Samba.Accounts.LoginForm do
  use Ash.Resource,
    otp_app: :samba,
    domain: Samba.Accounts

  code_interface do
    define :submit, action: :submit
  end

  actions do
    action :submit, :struct do
      argument :username, :string, allow_nil?: false
      argument :password, :string, allow_nil?: false

      # Tells Ash what type of structure the action returns on success
      constraints instance_of: Samba.Accounts.User

      run fn input, _context ->
        %{username: username, password: password} = input.arguments

        case Samba.Accounts.User.get_by_username(username) do
          {:ok, user} ->
            if Argon2.verify_pass(password, user.hashed_password) do
              {:ok, user}
            else
              {:error,
               Ash.Error.Changes.InvalidAttribute.exception(
                 field: :password,
                 message: "Invalid password"
               )}
            end

          {:error, _} ->
            {:error,
             Ash.Error.Changes.InvalidAttribute.exception(
               field: :username,
               message: "User not found"
             )}
        end
      end
    end
  end
end
