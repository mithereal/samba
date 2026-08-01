alias Ash.Generator
alias Samba.Accounts.UserGenerator
## Seed default ranks

PhpBB.Ranks.seed_default_ranks()
Samba.Analytics.DailyStat.seed_default_stats()

# priv/repo/seeds.exs
# Pull the site name from configuration
super_user = List.first(Application.get_env(:samba, :super_users)) || "admin@example.com"

IO.puts("Seeding admin user #{super_user}...")

# Generate and insert an admin user using the UserGenerator
admin_user =
  Samba.Accounts.UserGenerator.user(
    username: "admin",
    email: super_user,
    password: "AdminPassword123!",
    password_confirmation: "AdminPassword123!"
  )
  |> Ash.Generator.generate()

IO.puts("Successfully created admin user: #{admin_user.username} (#{admin_user.email})")

users = Generator.generate_many(UserGenerator.user(), 3)
