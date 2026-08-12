defmodule Samba.Core do
  use Ash.Domain,
    otp_app: :samba

  resources do
    resource Samba.Core.Fact
  end
end
