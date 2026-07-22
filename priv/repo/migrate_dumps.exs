# priv/repo/migrate_dumps.exs

data_dir = "priv/data_dumps"

IO.puts("Starting full phpBB2 CSV data migration...")

timed_import = fn name, fun, file ->
  IO.write("Importing #{name}...")
  {time, _} = :timer.tc(fn -> fun.(Path.join(data_dir, file)) end)
  IO.puts(" Done in #{div(time, 1_000)}ms")
end

# 1. Config & System
timed_import.("Config", &PhpBB.DataDumpLoader.import_config_csv/1, "config.csv")
timed_import.("Categories", &PhpBB.DataDumpLoader.import_categories_csv/1, "categories.csv")
timed_import.("Forums", &PhpBB.DataDumpLoader.import_forums_csv/1, "forums.csv")

# 2. Users & Groups
timed_import.("Groups", &PhpBB.DataDumpLoader.import_groups_csv/1, "groups.csv")
timed_import.("Users", &PhpBB.DataDumpLoader.import_users_csv/1, "users.csv")
timed_import.("User Groups", &PhpBB.DataDumpLoader.import_user_group_csv/1, "user_group.csv")

# 3. Core Content
timed_import.("Topics", &PhpBB.DataDumpLoader.import_topics_csv/1, "topics.csv")
timed_import.("Posts", &PhpBB.DataDumpLoader.import_posts_csv/1, "posts.csv")
timed_import.("Posts Text", &PhpBB.DataDumpLoader.import_posts_text_csv/1, "posts_text.csv")

IO.puts("Migration pipeline completed successfully!")