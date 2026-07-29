defmodule Samba.Accounts.Generator do
  use Ash.Resource,
    otp_app: :samba,
    domain: Samba.Accounts

  actions do
    action :generate_user, {:array, :struct} do
      argument :count, :integer, allow_nil?: false

      run fn input, ctx ->
        Samba.Accounts.UserGenerator.user()
        |> Ash.Generator.generate_many(input.arguments.count)
        |> then(&{:ok, &1})
      end
    end
  end
end
