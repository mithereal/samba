defmodule Samba.Ledger do
  use Ash.Domain,
    otp_app: :Samba

  resources do
    resource Samba.Ledger.Account
    resource Samba.Ledger.Balance
    resource Samba.Ledger.Transfer
  end
end
