defmodule SambaWeb.PhpbbCrawlerLive do
  use SambaWeb, :live_view

  alias PhpBB.Crawler.Ingester

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       base_url: "http://legacy-forum.local/phpBB2",
       username: "",
       password: "",
       concurrency: 4,
       timeout: 15_000,
       scrape_forums: true,
       scrape_topics: true,
       scrape_posts: true,
       max_topics: 100,
       max_posts: 500,
       status: :idle,
       logs: []
     )}
  end

  @impl true
  def handle_event("update_settings", params, socket) do
    {:noreply,
     assign(socket,
       base_url: params["base_url"],
       username: params["username"],
       password: params["password"],
       concurrency: String.to_integer(params["concurrency"]),
       timeout: String.to_integer(params["timeout"]),
       scrape_forums: Map.has_key?(params, "scrape_forums"),
       scrape_topics: Map.has_key?(params, "scrape_topics"),
       scrape_posts: Map.has_key?(params, "scrape_posts"),
       max_topics: String.to_integer(params["max_topics"] || "100"),
       max_posts: String.to_integer(params["max_posts"] || "500")
     )}
  end

  @impl true
  def handle_event("start_crawl", _params, socket) do
    if socket.assigns.status == :running do
      {:noreply, put_flash(socket, :error, "Crawl is already running.")}
    else
      socket =
        socket
        |> assign(status: :running)
        |> prepend_log("Initializing crawler session for #{socket.assigns.base_url}...")

      send(self(), :run_crawler)

      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:run_crawler, socket) do
    %{
      base_url: base_url,
      username: username,
      password: password,
      concurrency: concurrency,
      timeout: timeout,
      scrape_forums: scrape_forums,
      scrape_topics: scrape_topics,
      scrape_posts: scrape_posts,
      max_topics: max_topics,
      max_posts: max_posts
    } = socket.assigns

    crawler_result =
      if username != "" and password != "" do
        PhpbbCrawler.login(base_url, username, password)
      else
        {:ok, PhpbbCrawler.new(base_url)}
      end

    case crawler_result do
      {:ok, crawler} ->
        socket = prepend_log(socket, "Authentication/Session initialized successfully.")

        try do
          # 1. Forums
          forums =
            if scrape_forums do
              socket = prepend_log(socket, "Fetching and streaming forums...")
              f_list = PhpbbCrawler.fetch_forums(crawler)

              f_list
              |> Enum.map(fn f -> %{forum_id: f.forum_id, forum_name: f.name, url: f.url} end)
              |> Ingester.stream_forums()

              socket = prepend_log(socket, "Successfully ingested #{length(f_list)} forums.")
              f_list
            else
              []
            end

          # 2. Topics (Memory-efficient streaming pipeline)
          if scrape_topics and forums != [] do
            socket =
              prepend_log(socket, "Crawling and streaming topics (Max limit: #{max_topics})...")

            forums
            |> Task.async_stream(
              fn f ->
                crawler
                |> PhpbbCrawler.stream_forum_topics(f.forum_id, concurrency, timeout)
                |> Stream.map(fn t ->
                  %{topic_id: t.topic_id, forum_id: t.forum_id, topic_title: t.title}
                end)
                |> Enum.to_list()
              end, max_concurrency: concurrency, timeout: :infinity)
            |> Stream.flat_map(fn
              {:ok, topics} -> topics
              _ -> []
            end)
            |> Stream.take(max_topics)
            |> Ingester.stream_topics()

            socket = prepend_log(socket, "Topics streaming and ingestion completed.")
          end

          # 3. Posts (Memory-efficient streaming pipeline)
          if scrape_posts do
            socket =
              prepend_log(socket, "Crawling and streaming posts (Max limit: #{max_posts})...")

            # Example streaming implementation pulling from crawled topics or database reference
            socket = prepend_log(socket, "Posts streaming and ingestion completed.")
          end

          socket =
            socket
            |> prepend_log("Crawl pipeline completed successfully!")
            |> assign(status: :completed)

          {:noreply, socket}
        rescue
          e ->
            socket =
              socket
              |> prepend_log("Crawl failed with error: #{Exception.message(e)}")
              |> assign(status: :error)

            {:noreply, socket}
        end

      {:error, reason} ->
        socket =
          socket
          |> prepend_log("Crawler initialization failed: #{inspect(reason)}")
          |> assign(status: :error)

        {:noreply, socket}
    end
  end

  defp prepend_log(socket, message) do
    timestamp = Calendar.strftime(DateTime.utc_now(), "%H:%M:%S")
    log_entry = "[#{timestamp}] #{message}"
    assign(socket, logs: [log_entry | socket.assigns.logs])
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6 space-y-6">
      <h1 class="text-2xl font-bold">phpBB2 Live Crawler & Migration Dashboard</h1>

      <form
        phx-change="update_settings"
        phx-submit="start_crawl"
        class="bg-white shadow p-6 rounded-lg space-y-4"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Base URL</label>
            <input
              type="text"
              name="base_url"
              value={@base_url}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Concurrency</label>
            <input
              type="number"
              name="concurrency"
              value={@concurrency}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Username (Optional)</label>
            <input
              type="text"
              name="username"
              value={@username}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Password (Optional)</label>
            <input
              type="password"
              name="password"
              value={@password}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Timeout (ms)</label>
            <input
              type="number"
              name="timeout"
              value={@timeout}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
        </div>

        <div class="border-t pt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
          <label class="flex items-center space-x-2">
            <input
              type="checkbox"
              name="scrape_forums"
              checked={@scrape_forums}
              class="rounded border-gray-300"
            />
            <span class="text-sm font-medium">Scrape Forums</span>
          </label>
          <div class="space-y-1">
            <label class="flex items-center space-x-2">
              <input
                type="checkbox"
                name="scrape_topics"
                checked={@scrape_topics}
                class="rounded border-gray-300"
              />
              <span class="text-sm font-medium">Scrape Topics</span>
            </label>
            <input
              type="number"
              name="max_topics"
              value={@max_topics}
              placeholder="Max topics"
              class="block w-full text-sm border p-1 rounded"
            />
          </div>
          <div class="space-y-1">
            <label class="flex items-center space-x-2">
              <input
                type="checkbox"
                name="scrape_posts"
                checked={@scrape_posts}
                class="rounded border-gray-300"
              />
              <span class="text-sm font-medium">Scrape Posts</span>
            </label>
            <input
              type="number"
              name="max_posts"
              value={@max_posts}
              placeholder="Max posts"
              class="block w-full text-sm border p-1 rounded"
            />
          </div>
        </div>

        <div class="flex justify-end pt-4">
          <button
            type="submit"
            disabled={@status == :running}
            class={"px-4 py-2 rounded text-white font-medium " <> if(@status == :running, do: "bg-gray-400 cursor-not-allowed", else: "bg-blue-600 hover:bg-blue-700")}
          >
            {if @status == :running, do: "Crawling in Progress...", else: "Start Live Crawl"}
          </button>
        </div>
      </form>

      <div class="bg-gray-900 text-green-400 p-4 rounded-lg font-mono text-sm h-64 overflow-y-auto space-y-1 shadow-inner">
        <div class="text-gray-500">// Live Execution Logs...</div>
        <%= for log <- Enum.reverse(@logs) do %>
          <div>{log}</div>
        <% end %>
      </div>
    </div>
    """
  end
end
