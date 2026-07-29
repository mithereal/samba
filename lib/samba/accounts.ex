defmodule Samba.Accounts do
  require AshAuthentication.Strategies

  use Ash.Domain,
    otp_app: :samba,
    extensions: [AshOps]

  mix_tasks do
    action Samba.Accounts.Generator, :generate_user, :generate_user, arguments: [:count]
  end

  resources do
    resource Samba.Accounts.Token
    resource Samba.Accounts.Team
    resource Samba.Accounts.UserTeam

    resource Samba.Accounts.Group
    resource Samba.Accounts.UserGroup
    resource Samba.Accounts.GroupPermission

    resource Samba.Accounts.UserImpersonation

    resource Samba.Accounts.User do
      define :get_user_by_id, action: :read, get_by: :id
    end
    resource Samba.Accounts.Generator  # Add the resource to the Domain
  end
end
