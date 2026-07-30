defmodule Samba.Accounts.Generator do
  use Ash.Resource,
      otp_app: :samba,
      domain: Samba.Accounts,
      data_layer: :not_persisted

  actions do
    action :generate_user, {:array, :struct} do
      argument :count, :integer, allow_nil?: false, default: 1

      constraints items: [instance_of: Samba.Accounts.User]

      run fn input, _ctx ->
        users =
          Samba.Accounts.UserGenerator.user()
          |> Ash.Generator.generate_many(
               input.arguments.count,
               authorize?: false
             )

        {:ok, users}
      end
    end
  end
end