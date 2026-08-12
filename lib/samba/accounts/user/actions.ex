defmodule Samba.Accounts.User.Actions do
  use Spark.Dsl.Fragment, of: Ash.Resource

  actions do
    defaults [:read]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end

    read :admin_read do
      description "List users as admin"
      filter expr(teams.domain == ^actor(:current_team))
    end

    update :change_password do
      require_atomic? false
      accept []
      argument :current_password, :string, sensitive?: true, allow_nil?: false

      argument :password, :string,
        sensitive?: true,
        allow_nil?: false,
        constraints: [min_length: 8]

      argument :password_confirmation, :string, sensitive?: true, allow_nil?: false

      validate confirm(:password, :password_confirmation)

      validate {AshAuthentication.Strategy.Password.PasswordValidation,
                strategy_name: :password, password_argument: :current_password}

      change {AshAuthentication.Strategy.Password.HashPasswordChange, strategy_name: :password}
    end

    read :sign_in_with_password do
      description "Attempt to sign in using an email and password."
      get? true

      argument :email, :ci_string do
        description "The email to use for retrieving the user."
        allow_nil? false
      end

      argument :password, :string do
        description "The password to check for the matching user."
        allow_nil? false
        sensitive? true
      end

      prepare AshAuthentication.Strategy.Password.SignInPreparation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    action :sign_in_with_username, :struct do
      description "Attempt to sign in using a username and password."

      argument :username, :string do
        allow_nil? false
      end

      argument :password, :string do
        allow_nil? false
        sensitive? true
      end

      constraints instance_of: Samba.Accounts.User

      run fn input, _context ->
        %{username: username, password: password} = input.arguments

        case Samba.Accounts.User.get_by_username(%{username: username}, authorize?: false) do
          {:ok, user} when not is_nil(user) ->
            case Samba.Accounts.User.sign_in_with_password(
                   %{email: user.email, password: password},
                   authorize?: false
                 ) do
              {:ok, authenticated_user} ->
                {:ok, authenticated_user}

              {:error, error} ->
                {:error, error}
            end

          _ ->
            {:error,
             Ash.Error.Changes.InvalidAttribute.exception(
               field: :username,
               message: "User not found"
             )}
        end
      end
    end

    read :sign_in_with_token do
      description "Attempt to sign in using a short-lived sign in token."
      get? true

      argument :token, :string do
        allow_nil? false
        sensitive? true
      end

      prepare AshAuthentication.Strategy.Password.SignInWithTokenPreparation

      metadata :token, :string do
        allow_nil? false
      end
    end

    create :register_with_password do
      description "Register a new user with an email and password."

      argument :email, :ci_string do
        allow_nil? false
      end

      argument :password, :string do
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :password_confirmation, :string do
        allow_nil? false
        sensitive? true
      end

      argument :altcha, :string, allow_nil?: false
      change Samba.Changes.VerifyAltcha

      change set_attribute(:email, arg(:email))

      change fn changeset, _context ->
        case Ash.Changeset.get_argument(changeset, :email) do
          email when is_binary(email) or not is_nil(email) ->
            [username | _] = String.split(to_string(email), "@")
            Ash.Changeset.force_change_attribute(changeset, :username, username)

          _ ->
            changeset
        end
      end

      change AshAuthentication.Strategy.Password.HashPasswordChange
      change AshAuthentication.GenerateTokenChange
      change Samba.Accounts.User.Changes.CreatePhpbbUser

      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation

      metadata :token, :string do
        allow_nil? false
      end
    end

    action :request_password_reset_token do
      description "Send password reset instructions to a user if they exist."

      argument :email, :ci_string do
        allow_nil? false
      end

      run {AshAuthentication.Strategy.Password.RequestPasswordReset, action: :get_by_email}
    end

    read :get_by_email do
      description "Looks up a user by their email"
      get? true

      argument :email, :ci_string do
        allow_nil? false
      end

      filter expr(email == ^arg(:email))
    end

    update :reset_password_with_token do
      argument :reset_token, :string do
        allow_nil? false
        sensitive? true
      end

      argument :password, :string do
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :password_confirmation, :string do
        allow_nil? false
        sensitive? true
      end

      validate AshAuthentication.Strategy.Password.ResetTokenValidation
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation

      change AshAuthentication.Strategy.Password.HashPasswordChange
      change AshAuthentication.GenerateTokenChange
    end

    create :sign_in_with_magic_link do
      description "Sign in or register a user with magic link."

      argument :token, :string do
        allow_nil? false
      end

      upsert? true
      upsert_identity :unique_email
      upsert_fields [:email]

      change AshAuthentication.Strategy.MagicLink.SignInChange

      metadata :token, :string do
        allow_nil? false
      end
    end

    action :request_magic_link do
      argument :email, :ci_string do
        allow_nil? false
      end

      run AshAuthentication.Strategy.MagicLink.Request
    end

    update :set_current_team do
      description "Set user's current team"

      argument :team, :string do
        allow_nil? false
        sensitive? false
      end

      change set_attribute(:current_team, arg(:team))
    end

    update :update_phpbb_user_id do
      description "Set phpbbid"
      accept []

      argument :phpbb_user_id, :integer do
        allow_nil? false
        sensitive? false
      end

      change set_attribute(:phpbb_user_id, arg(:phpbb_user_id))
    end

    update :switch_team_to do
      description "Swith user team to the new one"
      argument :team, :string
      validate Samba.Accounts.User.Validations.ValidateBelongsToTeam
      change set_attribute(:current_team, arg(:team))
    end

    create :invite do
      description "Invite a new user to the team"
      accept [:email]

      validate Samba.Accounts.User.Validations.ValidateNewToTeam
      manual Samba.Accounts.User.Actions.CreateUserIfNotExists
      change Samba.Accounts.User.Changes.AddToTeam
    end

    action :force_sign_in, :map do
      description "Force login without knowing user password. Only for super admins"

      argument :conn, :map
      argument :purpose, :string
      argument :user_id, :uuid

      run Samba.Accounts.User.Actions.ForceSignIn
    end

    read :get_by_username do
      argument :username, :string, allow_nil?: false
      get? true
      filter expr(username == ^arg(:username))
    end
  end

  code_interface do
    define :force_sign_in, action: :force_sign_in
    define :sign_in_with_username, action: :sign_in_with_username
    define :get_by_username, action: :get_by_username
    define :sign_in_with_password, action: :sign_in_with_password
  end
end
