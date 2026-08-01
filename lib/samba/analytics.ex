defmodule Samba.Analytics do
  use Ash.Domain,
    otp_app: :samba

  resources do
    resource Samba.Analytics.DailyStat
  end
end
