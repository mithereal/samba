defmodule PhpbbCrawler do
  @moduledoc """
  A production-grade recursive web crawler and scraper for legacy phpBB2 forums supporting
  both public (anonymous) and authenticated scraping built with Elixir, Finch, and Floki.

  It automatically walks the board hierarchy—from index categories to individual forums,
  paginated topic threads, posts, and user profiles—utilizing concurrent streams and built-in rate limiting to safely migrate data without overwhelming legacy server infrastructure

  ## Examples

      # 1. Initialize an anonymous (public) scraper session
      crawler = PhpbbCrawler.new("http://legacy-forum.local/phpBB2")

      # 2. Alternatively, authenticate to access protected boards
      {:ok, crawler} = PhpbbCrawler.login("http://legacy-forum.local/phpBB2", "admin", "secret_pass")

      # 3. Execute the full recursive crawl
      scraped_data = PhpbbCrawler.crawl_all(crawler)

      # 4. Alternatively, setting concurrency and timeout
      scraped_data = PhpbbCrawler.crawl_all(crawler, 4, 15_000)

      IO.inspect(length(scraped_data.forums), label: "Total Forums")
      IO.inspect(length(scraped_data.topics), label: "Total Topics")
      IO.inspect(length(scraped_data.posts), label: "Total Posts")
  """

  @concurrency 4
  @timeout 15_000

  defstruct [:base_url, :cookie, :finch_name]

  @doc """
  Initializes a public (unauthenticated) crawler session.
  """
  def new(base_url, opts \\ []) do
    finch_name = Keyword.get(opts, :finch_name, default_finch_name())
    %PhpbbCrawler{base_url: base_url, cookie: nil, finch_name: finch_name}
  end

  @doc """
  Logs into the phpBB2 forum and returns an authenticated crawler struct.
  """
  def login(base_url, username, password, opts \\ []) do
    finch_name = Keyword.get(opts, :finch_name, default_finch_name())
    login_url = "#{base_url}/login.php"

    form_data =
      URI.encode_query(%{
        "username" => username,
        "password" => password,
        "login" => "Log in",
        "redirect" => ""
      })

    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    case Finch.build(:post, login_url, headers, form_data) |> Finch.request(finch_name) do
      {:ok, %Finch.Response{status: status, headers: resp_headers}} when status in [200, 302] ->
        cookie = extract_session_cookie(resp_headers)

        if cookie do
          IO.puts("Successfully authenticated session.")
          {:ok, %PhpbbCrawler{base_url: base_url, cookie: cookie, finch_name: finch_name}}
        else
          {:error, "Login succeeded but failed to extract session cookie."}
        end

      {:ok, %Finch.Response{status: status}} ->
        {:error, "Login failed with HTTP status: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Starts a full crawl (works whether the struct has a cookie or is nil).
  """
  def crawl_all(%PhpbbCrawler{} = crawler, concurrency \\ @concurrency, timeout \\ @timeout) do
    mode_msg = if crawler.cookie, do: "authenticated", else: "public (unauthenticated)"
    IO.puts("Starting #{mode_msg} crawl of #{crawler.base_url}...")

    forums = fetch_forums(crawler)
    IO.puts("Found #{length(forums)} forums.")

    all_topics =
      forums
      |> Task.async_stream(
        fn forum -> crawl_forum_pages(crawler, forum.forum_id, 0, [], concurrency, timeout) end,
        max_concurrency: concurrency,
        timeout: timeout
      )
      |> Enum.flat_map(fn
        {:ok, topics} -> topics
        {:error, _} -> []
      end)

    IO.puts("Found #{length(all_topics)} total topics across all forums.")

    all_posts =
      all_topics
      |> Task.async_stream(
        fn topic -> crawl_topic_pages(crawler, topic.topic_id, 0, [], concurrency, timeout) end,
        max_concurrency: concurrency,
        timeout: timeout
      )
      |> Enum.flat_map(fn
        {:ok, posts} -> posts
        {:error, _} -> []
      end)

    IO.puts("Crawled #{length(all_posts)} total posts.")

    %{
      forums: forums,
      topics: all_topics,
      posts: all_posts
    }
  end

  # --- Crawlers ---

  def fetch_forums(%PhpbbCrawler{} = crawler) do
    case get_request(crawler, "#{crawler.base_url}/index.php") do
      {:ok, body} -> parse_forums(body, crawler.base_url)
      _ -> []
    end
  end

  defp crawl_forum_pages(crawler, forum_id, start, acc, concurrency, timeout) do
    url = "#{crawler.base_url}/viewforum.php?f=#{forum_id}&start=#{start}"

    case get_request(crawler, url, timeout) do
      {:ok, body} ->
        {topics, next_start} = parse_topics_with_pagination(body, crawler.base_url, forum_id)
        updated_acc = acc ++ topics

        if next_start && next_start > start do
          Process.sleep(250)
          crawl_forum_pages(crawler, forum_id, next_start, updated_acc, concurrency, timeout)
        else
          updated_acc
        end

      _ ->
        acc
    end
  end

  defp crawl_topic_pages(crawler, topic_id, start, acc, concurrency, timeout) do
    url = "#{crawler.base_url}/viewtopic.php?t=#{topic_id}&start=#{start}"

    case get_request(crawler, url, timeout) do
      {:ok, body} ->
        {posts, next_start} = parse_posts_with_pagination(body, topic_id)
        updated_acc = acc ++ posts

        if next_start && next_start > start do
          Process.sleep(250)
          crawl_topic_pages(crawler, topic_id, next_start, updated_acc, concurrency, timeout)
        else
          updated_acc
        end

      _ ->
        acc
    end
  end

  # --- HTTP Request Wrapper (Conditional Cookie Injection) ---

  defp get_request(
         %PhpbbCrawler{cookie: cookie, finch_name: finch_name},
         url,
         receive_timeout \\ 15_000
       ) do
    headers = if cookie, do: [{"cookie", cookie}], else: []
    pool_name = finch_name || default_finch_name()

    case Finch.build(:get, url, headers)
         |> Finch.request(pool_name, receive_timeout: receive_timeout) do
      {:ok, %Finch.Response{status: 200, body: body}} -> {:ok, body}
      {:ok, %Finch.Response{status: status}} -> {:error, "HTTP #{status}"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp default_finch_name do
    Application.get_env(:samba, :finch_name, Finch)
  end

  defp extract_session_cookie(headers) do
    headers
    |> Enum.filter(fn {k, _v} -> String.downcase(k) == "set-cookie" end)
    |> Enum.map(fn {_k, v} -> v |> String.split(";") |> List.first() end)
    |> Enum.join("; ")
    |> case do
      "" -> nil
      cookies -> cookies
    end
  end

  # --- Parsers & Helpers ---

  defp parse_forums(html, base_url) do
    {:ok, doc} = Floki.parse_document(html)

    doc
    |> Floki.find("a.forumlink, a[href*='viewforum.php']")
    |> Enum.map(fn el ->
      name = Floki.text(el)
      href = Floki.attribute(el, "href") |> List.first()

      %{
        forum_id: extract_id(href, "f"),
        name: String.trim(name),
        url: build_absolute_url(base_url, href)
      }
    end)
    |> Enum.reject(&is_nil(&1.forum_id))
    |> Enum.uniq_by(& &1.forum_id)
  end

  defp parse_topics_with_pagination(html, base_url, forum_id) do
    {:ok, doc} = Floki.parse_document(html)

    topics =
      doc
      |> Floki.find("a.topictitle")
      |> Enum.map(fn el ->
        title = Floki.text(el)
        href = Floki.attribute(el, "href") |> List.first()

        %{
          topic_id: extract_id(href, "t"),
          forum_id: forum_id,
          title: String.trim(title),
          url: build_absolute_url(base_url, href)
        }
      end)
      |> Enum.reject(&is_nil(&1.topic_id))

    next_start = extract_next_pagination(doc, "f=#{forum_id}")
    {topics, next_start}
  end

  defp parse_posts_with_pagination(html, topic_id) do
    {:ok, doc} = Floki.parse_document(html)

    posts =
      doc
      |> Floki.find("table.forumline tr")
      |> Enum.flat_map(fn row ->
        author_el = Floki.find(row, ".name")
        body_el = Floki.find(row, ".postbody")

        if author_el != [] and body_el != [] do
          author = author_el |> Floki.text() |> String.trim()
          content = body_el |> Floki.text() |> String.trim()

          profile_href = Floki.find(author_el, "a") |> Floki.attribute("href") |> List.first()
          user_id = extract_id(profile_href, "u")

          post_id_attr = Floki.find(row, "a[name]") |> Floki.attribute("name") |> List.first()
          post_id = parse_post_id(post_id_attr)

          [
            %{
              post_id: post_id,
              topic_id: topic_id,
              user_id: user_id,
              author: author,
              content: content
            }
          ]
        else
          []
        end
      end)

    next_start = extract_next_pagination(doc, "t=#{topic_id}")
    {posts, next_start}
  end

  defp extract_next_pagination(doc, query_context) do
    doc
    |> Floki.find("a.nav, .gensmall a")
    |> Enum.filter(fn el ->
      href = Floki.attribute(el, "href") |> List.first() || ""
      String.contains?(href, query_context) and String.contains?(href, "start=")
    end)
    |> Enum.map(fn el ->
      href = Floki.attribute(el, "href") |> List.first()
      extract_id(href, "start")
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.max(fn -> nil end)
  end

  defp extract_id(nil, _param), do: nil

  defp extract_id(path, param) do
    case URI.parse(path).query |> URI.decode_query() |> Map.get(param) do
      nil -> nil
      val -> String.to_integer(val)
    end
  rescue
    _ -> nil
  end

  defp parse_post_id(nil), do: nil

  defp parse_post_id(name_attr) do
    case Integer.parse(String.replace_prefix(name_attr, "p", "")) do
      {id, ""} -> id
      _ -> nil
    end
  end

  defp build_absolute_url(base_url, relative_path) do
    uri = URI.parse(base_url)
    base = "#{uri.scheme}://#{uri.host}"
    cleaned = String.replace_prefix(relative_path || "", "./", "")

    if String.starts_with?(cleaned, "http") do
      cleaned
    else
      Path.join([base, cleaned])
    end
  end

  @doc """
  Lazily streams topics across all pages of a forum.
  """
  def stream_forum_topics(crawler, forum_id, concurrency \\ 4, timeout \\ 15_000) do
    Stream.resource(
      fn -> {0, false} end,
      fn
        {_, true} ->
          {:halt, nil}

        {start, _} ->
          url = "#{crawler.base_url}/viewforum.php?f=#{forum_id}&start=#{start}"

          case get_request(crawler, url, timeout) do
            {:ok, body} ->
              {topics, next_start} =
                parse_topics_with_pagination(body, crawler.base_url, forum_id)

              if next_start && next_start > start do
                # Gentle rate limiting
                Process.sleep(100)
                {topics, {next_start, false}}
              else
                {topics, {0, true}}
              end

            _ ->
              {:halt, nil}
          end
      end,
      fn _ -> :ok end
    )
  end

  @doc """
  Lazily streams posts across all pages of a topic.
  """
  def stream_topic_posts(crawler, topic_id, concurrency \\ 4, timeout \\ 15_000) do
    Stream.resource(
      fn -> {0, false} end,
      fn
        {_, true} ->
          {:halt, nil}

        {start, _} ->
          url = "#{crawler.base_url}/viewtopic.php?t=#{topic_id}&start=#{start}"

          case get_request(crawler, url, timeout) do
            {:ok, body} ->
              {posts, next_start} = parse_posts_with_pagination(body, topic_id)

              if next_start && next_start > start do
                Process.sleep(100)
                {posts, {next_start, false}}
              else
                {posts, {0, true}}
              end

            _ ->
              {:halt, nil}
          end
      end,
      fn _ -> :ok end
    )
  end
end
