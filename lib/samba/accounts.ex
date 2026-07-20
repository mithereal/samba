defmodule Samba.Accounts do
  use Ash.Domain,
    otp_app: :samba

  resources do
    resource Samba.Accounts.Token
    resource Samba.Accounts.User
    resource Samba.Accounts.Team
    resource Samba.Accounts.UserTeam

    resource Samba.Accounts.Group
    resource Samba.Accounts.UserGroup
    resource Samba.Accounts.GroupPermission

    resource Samba.Accounts.UserImpersonation
  end
end
