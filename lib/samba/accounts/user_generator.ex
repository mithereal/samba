defmodule Samba.Accounts.UserGenerator do
  alias Ash.Generator
  alias Samba.Accounts.User

  def user(opts \\ []) do
    Generator.changeset_generator(
      User,
      :register_with_password,
      defaults: [
        username: StreamData.repeatedly(fn -> Faker.Internet.user_name() end),
        email: StreamData.repeatedly(fn -> Faker.Internet.email() end),
        password: "Passw0rd",
        password_confirmation: "Passw0rd"
      ],
      overrides: opts
    )
  end
end
