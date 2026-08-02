defmodule Samba.Accounts.User.Changes.CreatePhpbbUser do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn changeset, user ->
      require Logger
      Logger.warning("--- RUNNING PHPBB AFTER_ACTION FOR: #{user.email} ---")

      username = Ash.Changeset.get_attribute(changeset, :username) || user.username
      email = Ash.Changeset.get_attribute(changeset, :email) || user.email

      hashed_password =
        case Ash.Changeset.get_attribute(changeset, :hashed_password) do
          nil -> Map.get(changeset.attributes, :hashed_password, "0")
          val -> val
        end

      case PhpBB.Users
           |> Ash.Changeset.for_create(:create, %{
             username: username,
             user_email: to_string(email),
             user_password: hashed_password,
             user_regdate: System.system_time(:second),
             user_rank: 3,
             user_active: true
           })
           |> Ash.create(domain: PhpBB.Domain, authorize?: false) do
        {:ok, phpbb_user} ->
          Logger.warning("--- SUCCESSFULLY CREATED PHPBB USER ID: #{phpbb_user.user_id} ---")

          user_id_value =
            case phpbb_user.user_id do
              id when is_binary(id) -> String.to_integer(id)
              id -> id
            end

          case user
               |> Ash.Changeset.for_update(:update_phpbb_user_id, %{phpbb_user_id: user_id_value})
               |> Ash.update(authorize?: false) do
            {:ok, updated_user} ->
              {:ok, updated_user}

            {:error, error} ->
              Logger.error("--- FAILED TO UPDATE USER WITH PHPBB_USER_ID: #{inspect(error)} ---")
              {:error, error}
          end

        {:error, reason} ->
          Logger.error("--- FAILED TO CREATE PHPBB USER: #{inspect(reason)} ---")
          {:error, reason}
      end
    end)
  end
end
