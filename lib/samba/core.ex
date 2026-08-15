defmodule Samba.Core do
  use Ash.Domain,
    otp_app: :samba,
    extensions: [AshOps]

  resources do
    resource Samba.Core.Fact
    resource Samba.Core.Page
    resource Samba.Core.Settings
  end
end
