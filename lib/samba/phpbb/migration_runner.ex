defmodule PhpBB.MigrationRunner do
  alias PhpBB.Crawler.Ingester

  def run(base_url, username \\ nil, password \\ nil) do
    crawler =
      case {username, password} do
        {nil, nil} ->
          PhpbbCrawler.new(base_url)

        {u, p} ->
          {:ok, c} = PhpbbCrawler.login(base_url, u, p)
          c
      end

    # 1. Execute the crawl
    scraped_data = PhpbbCrawler.crawl_all(crawler)

    IO.puts("Starting data ingestion into AshPostgres...")

    # 2. Stream and upsert forums
    scraped_data.forums
    |> Stream.map(& &1)
    |> Ingester.stream_forums()

    # 3. Stream and upsert topics
    scraped_data.topics
    |> Stream.map(& &1)
    |> Ingester.stream_topics()

    # 4. Stream and upsert posts
    scraped_data.posts
    |> Stream.map(& &1)
    |> Ingester.stream_posts()

    IO.puts("Migration pipeline completed successfully.")
  end
end
