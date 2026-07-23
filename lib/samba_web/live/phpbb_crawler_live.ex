defmodule SambaWeb.PhpbbCrawlerLive do
  use SambaWeb, :live_view

  alias PhpBB.Crawler.Ingester

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      assign(socket,
        base_url: "http://legacy-forum.local/phpBB2",
        require_login: false,
        username: "",
        password: "",
        concurrency: 4,
        timeout: 15_000,
        scrape_forums: true,
        scrape_topics: true,
        scrape_posts: true,
        scrape_profiles: true,
        download_assets: false,
        asset_dir: "./priv/forum_assets",
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
        require_login: Map.has_key?(params, "require_login"),
        username: params["username"],
        password: params["password"],
        concurrency: String.to_integer(params["concurrency"]),
        timeout: String.to_integer(params["timeout"]),
        scrape_forums: Map.has_key?(params, "scrape_forums"),
        scrape_topics: Map.has_key?(params, "scrape_topics"),
        scrape_posts: Map.has_key?(params, "scrape_posts"),
        scrape_profiles: Map.has_key?(params, "scrape_profiles"),
        download_assets: Map.has_key?(params, "download_assets"),
        asset_dir: params["asset_dir"],
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
      require_login: require_login,
      username: username,
      password: password,
      concurrency: concurrency,
      timeout: timeout,
      scrape_forums: scrape_forums,
      scrape_topics: scrape_topics,
      scrape_posts: scrape_posts,
      scrape_profiles: scrape_profiles,
      download_assets: download_assets,
      asset_dir: asset_dir,
      max_topics: max_topics,
      max_posts: max_posts
    } = socket.assigns

    crawler_opts = [
      download_assets: download_assets,
      asset_dir: asset_dir
    ]

    crawler_result =
      if require_login and username != "" and password != "" do
        prepend_log(socket, "Attempting authentication login as '#{username}'...")
        PhpbbCrawler.login(base_url, username, password, crawler_opts)
      else
        if require_login and (username == "" or password == "") do
          {:error, "Login is enabled, but username or password fields are empty."}
        else
          {:ok, PhpbbCrawler.new(base_url, crawler_opts)}
        end
      end

    case crawler_result do
      {:ok, crawler} ->
        mode_label = if crawler.cookie, do: "Authenticated Session (Emails unlocked)", else: "Public Anonymous Session"
        socket = prepend_log(socket, "Crawler session initialized successfully. Mode: #{mode_label}.")

        try do
          # 1. Forums Pipeline (Streamed & Sanitized)
          forums =
            if scrape_forums do
              socket = prepend_log(socket, "Fetching and streaming forums...")
              f_list = PhpbbCrawler.fetch_forums(crawler)

              f_list
              |> Stream.map(fn f -> Map.drop(f, [:url]) end)
              |> Ingester.stream_forums()

              socket = prepend_log(socket, "Successfully ingested #{length(f_list)} forums.")
              f_list
            else
              []
            end

          # 2. Topics Pipeline (Streamed & Sanitized)
          crawled_topics =
            if scrape_topics and forums != [] do
              socket =
                prepend_log(socket, "Crawling and streaming topics (Max limit: #{max_topics})...")

              topics_stream =
                forums
                |> Task.async_stream(
                     fn f ->
                       crawler
                       |> PhpbbCrawler.stream_forum_topics(f.forum_id, concurrency, timeout)
                       |> Stream.map(fn t -> Map.drop(t, [:url]) end)
                     end, max_concurrency: concurrency, timeout: :infinity)
                |> Stream.flat_map(fn
                  {:ok, stream} -> stream
                  _ -> []
                end)
                |> Stream.take(max_topics)

              topics_stream
              |> Ingester.stream_topics()

              # Collect into list for downstream posts dependency
              topics_list = Enum.to_list(topics_stream)

              socket = prepend_log(socket, "Topics streaming and ingestion completed (#{length(topics_list)} topics).")
              topics_list
            else
              []
            end

          # 3. Posts Pipeline (Streamed & Sanitized)
          crawled_posts =
            if scrape_posts and crawled_topics != [] do
              socket =
                prepend_log(socket, "Crawling and streaming posts (Max limit: #{max_posts})...")

              posts_stream =
                crawled_topics
                |> Task.async_stream(
                     fn t ->
                       crawler
                       |> PhpbbCrawler.stream_topic_posts(t.topic_id, concurrency, timeout)
                     end, max_concurrency: concurrency, timeout: :infinity)
                |> Stream.flat_map(fn
                  {:ok, stream} -> stream
                  _ -> []
                end)
                |> Stream.take(max_posts)

              if function_exported?(Ingester, :stream_posts, 1) do
                Ingester.stream_posts(posts_stream)
              else
                Stream.run(posts_stream)
              end

              posts_list = Enum.to_list(posts_stream)

              socket = prepend_log(socket, "Posts streaming and ingestion completed (#{length(posts_list)} posts).")
              posts_list
            else
              []
            end

          # 4. User Profiles & Avatars Pipeline
          if scrape_profiles and crawled_posts != [] do
            socket = prepend_log(socket, "Extracting user profiles and avatars (Authenticated emails extraction: #{!!crawler.cookie})...")

            unique_user_ids =
              crawled_posts
              |> Enum.map(& &1.user_id)
              |> Enum.reject(&is_nil/1)
              |> Enum.uniq()

            profiles_stream =
              unique_user_ids
              |> Task.async_stream(
                   fn user_id -> PhpbbCrawler.crawl_user_profile(crawler, user_id) end,
                   max_concurrency: concurrency,
                   timeout: timeout
                 )
              |> Stream.flat_map(fn
                {:ok, profile} when not is_nil(profile) -> [profile]
                _ -> []
              end)

            if function_exported?(Ingester, :stream_profiles, 1) do
              Ingester.stream_profiles(profiles_stream)
            else
              Stream.run(profiles_stream)
            end

            profiles_count = Enum.count(unique_user_ids)
            socket = prepend_log(socket, "Successfully processed user profiles & assets pipeline.")
            socket
          else
            socket
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
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
    <div class="max-w-4xl mx-auto p-6 space-y-6 mb-4">
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
            <label class="block text-sm font-medium text-gray-700">Username</label>
            <input
              type="text"
              name="username"
              value={@username}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Password</label>
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
          <div>
            <label class="block text-sm font-medium text-gray-700">Asset Directory</label>
            <input
              type="text"
              name="asset_dir"
              value={@asset_dir}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm border p-2"
            />
          </div>
        </div>

        <div class="border-t pt-4">
          <label class="flex items-center space-x-2">
            <input
              type="checkbox"
              name="require_login"
              checked={@require_login}
              class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <span class="text-sm font-semibold text-gray-800">Enable Authentication (Required for downloading hidden profile emails)</span>
          </label>
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

        <div class="border-t pt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
          <label class="flex items-center space-x-2">
            <input
              type="checkbox"
              name="scrape_profiles"
              checked={@scrape_profiles}
              class="rounded border-gray-300"
            />
            <span class="text-sm font-medium">Scrape User Profiles & Emails</span>
          </label>
          <label class="flex items-center space-x-2">
            <input
              type="checkbox"
              name="download_assets"
              checked={@download_assets}
              class="rounded border-gray-300"
            />
            <span class="text-sm font-medium">Download Avatars & Post Images to Disk</span>
          </label>
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
    </Layouts.app>
    """
  end
end