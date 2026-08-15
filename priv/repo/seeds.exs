alias Ash.Generator
alias Samba.Generators.User
alias Samba.Generators.Fact
## Seed default ranks

PhpBB.Ranks.seed_default_ranks()
Samba.Analytics.DailyStat.seed_default_stats()

# priv/repo/seeds.exs
# Pull the site name from configuration
super_user = List.first(Application.get_env(:samba, :super_users)) || "admin@example.com"
default_password = System.get_env("DEFAULT_ADMIN_PASSWORD") || "AdminPassword123!"

IO.puts("Seeding admin user #{super_user}...")

# Generate and insert an admin user using the UserGenerator
admin_user =
  User.user(
    username: "admin",
    email: super_user,
    password: default_password,
    password_confirmation: default_password
  )
  |> Ash.Generator.generate()

IO.puts("Successfully created admin user: #{admin_user.username} (#{admin_user.email})")

users = Generator.generate_many(User.user(), 3)
facts = Generator.generate_many(Fact.fact(), 3)

Samba.SelfCertGenerator.generate_self_signed()
