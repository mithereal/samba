defmodule SambaWeb.PostsLive do
  use SambaWeb, :live_view

  require Ash.Query

  def mount(%{"id" => topic_id} = params, _session, socket) do
    topic_id = parse_int(topic_id)
    page = parse_int(params["page"], 1)
    per_page = parse_int(params["per_page"], 15)
    offset_val = (page - 1) * per_page

    topic =
      PhpBB.Topics
      |> Ash.Query.filter(topic_id == ^topic_id)
      |> Ash.Query.load([:forum])
      |> Ash.read_one!(domain: PhpBB.Domain)

    if topic do
      topic
      |> Ash.Changeset.for_update(:increment_views, %{})
      |> Ash.update!(domain: PhpBB.Domain)
    end

    paginated_query =
      PhpBB.Posts
      |> Ash.Query.filter(topic_id == ^topic_id)
      |> Ash.Query.sort(post_time: :asc)
      |> Ash.Query.load([:poster, :post_text])
      |> Ash.Query.page(limit: per_page, offset: offset_val)

    page_results = Ash.read!(paginated_query, domain: PhpBB.Domain)

    # Initialize empty form state for reply
    form = to_form(%{"message" => "", "subject" => ""})

    socket =
      socket
      |> assign(:page_title, (topic && topic.topic_title) || "Topic")
      |> assign(:topic, topic)
      |> assign(:posts, page_results.results || [])
      |> assign(:page, page)
      |> assign(:per_page, per_page)
      |> assign(:more?, page_results.more?)
      |> assign(:topic_id, topic_id)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("change-per-page", %{"per_page" => per_page}, socket) do
    {:noreply,
     push_navigate(socket, to: ~p"/topic/#{socket.assigns.topic_id}?page=1&per_page=#{per_page}")}
  end

  def handle_event("quote-post", %{"id" => post_id}, socket) do
    post_id = parse_int(post_id)
    post = Enum.find(socket.assigns.posts, &(&1.post_id == post_id))

    if post do
      author = (post.poster && post.poster.username) || "User"
      content = (post.post_text && post.post_text.post_text) || ""
      quoted_text = "[quote=\"#{author}\"]#{content}[/quote]\n"

      current_msg = socket.assigns.form["message"].value || ""
      new_msg = current_msg <> quoted_text

      form =
        to_form(%{"message" => new_msg, "subject" => "Re: #{socket.assigns.topic.topic_title}"})

      {:noreply, assign(socket, :form, form)}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "save-reply",
        %{"reply" => %{"message" => message, "subject" => subject}},
        socket
      ) do
    topic = socket.assigns.topic
    poster_id = (socket.assigns[:current_user] && socket.assigns.current_user.user_id) || 1
    now = System.system_time(:second)

    # 1. Run creation in the transaction and collect notifications
    result =
      Samba.Repo.transaction(fn ->
        with {:ok, post, notifications_post} <-
               PhpBB.Posts
               |> Ash.Changeset.for_create(:create, %{
                 topic_id: topic.topic_id,
                 forum_id: topic.forum_id,
                 poster_id: poster_id,
                 post_time: now,
                 poster_ip: 0,
                 enable_bbcode: 1,
                 enable_html: 0,
                 enable_smilies: 1,
                 enable_sig: 1
               })
               |> Ash.create(domain: PhpBB.Domain, return_notifications?: true),
             {:ok, _posts_text, notifications_text} <-
               PhpBB.PostsText
               |> Ash.Changeset.for_create(:create, %{
                 post_id: post.post_id,
                 bbcode_uid: "",
                 post_subject: subject,
                 post_text: message
               })
               |> Ash.create(domain: PhpBB.Domain, return_notifications?: true) do
          {post, notifications_post ++ notifications_text}
        else
          {:error, reason} -> Samba.Repo.rollback(reason)
        end
      end)

    case result do
      {:ok, {post, notifications}} ->
        # 2. Dispatch the missed notifications safely now that the transaction is committed
        Ash.Notifier.notify(notifications)

        {:noreply,
         socket
         |> put_flash(:info, "Reply posted successfully!")
         |> push_navigate(to: ~p"/topic/#{topic.topic_id}")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to post reply.")}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <div class="w-full mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
      <!-- Breadcrumb & Header -->
      <div class="mb-6">
        <h1 class="text-2xl font-bold tracking-tight text-black">{@topic && @topic.topic_title}</h1>
        <.breadcrumb>
          <:item icon="hero-folder" link="/form">Forum Index</:item>
          <:item
            icon="hero-folder-open"
            link={(@topic && @topic.forum_id && ~p"/forum/#{@topic.forum_id}") || "/"}
          >
            {(@topic && @topic.forum && @topic.forum.forum_name) || "Forum"}
          </:item>
          <:item icon="hero-document-text" link="#">{@topic && @topic.topic_title}</:item>
        </.breadcrumb>
      </div>

      <!-- Posts Listing Container -->
      <div class="space-y-4 mb-8">
        <%= if length(@posts) == 0 do %>
          <div class="bg-gray-900/80 border border-gray-700 rounded-lg px-6 py-8 text-center text-gray-500 italic">
            No posts found for this topic.
          </div>
        <% else %>
          <%= for post <- @posts do %>
            <.post_card post={post} />
          <% end %>
        <% end %>
      </div>

      <!-- Pagination Footer -->
      <div class="flex flex-col sm:flex-row items-center justify-between mb-8 px-2 gap-4">
        <div class="flex space-x-2">
          <%= if @page > 1 do %>
            <.link
              patch={~p"/topic/#{@topic_id}?page=#{@page - 1}&per_page=#{@per_page}"}
              class="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-md text-sm font-medium border border-gray-700 transition-colors"
            >
              &larr; Previous
            </.link>
          <% end %>

          <%= if @more? do %>
            <.link
              patch={~p"/topic/#{@topic_id}?page=#{@page + 1}&per_page=#{@per_page}"}
              class="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-md text-sm font-medium border border-gray-700 transition-colors"
            >
              Next &rarr;
            </.link>
          <% end %>
        </div>

        <form phx-change="change-per-page" class="inline">
          <span class="text-black text-sm">Posts per page:</span>
          <select
            name="per_page"
            class="bg-gray-800 border border-gray-700 text-white rounded px-2 py-1 text-sm focus:outline-none focus:border-indigo-500"
          >
            <%= for count <- [10, 15, 25, 50] do %>
              <option value={count} selected={@per_page == count}>{count}</option>
            <% end %>
          </select>
        </form>
      </div>
    </div>
    """
  end

  defp post_card(assigns) do
    ~H"""
    <div
      id={"post-#{@post.post_id}"}
      class="grid grid-cols-1 md:grid-cols-12 bg-gray-900/80 border border-gray-700 rounded-lg shadow-xl overflow-hidden backdrop-blur-md"
    >
      <!-- Author Sidebar -->
      <div class="md:col-span-3 bg-gray-800/60 p-4 border-b md:border-b-0 md:border-r border-gray-700 flex flex-col justify-between">
        <div>
          <div class="font-bold text-indigo-300 text-base mb-1">
            {(@post.poster && @post.poster.username) || "Anonymous"}
          </div>
          <div class="text-xs text-gray-400">
            Joined: {format_timestamp(@post.poster && @post.poster.user_regdate)}
          </div>
        </div>
      </div>

      <!-- Post Content Body -->
      <div class="md:col-span-9 p-6 flex flex-col justify-between">
        <div>
          <div class="flex justify-between items-center border-b border-gray-800 pb-2 mb-4 text-xs text-gray-400">
            <span>Posted: {format_timestamp(@post.post_time)}</span>
            <div class="flex items-center space-x-3">
              <span>Post ID: #{@post.post_id}</span>
              <button
                phx-click="quote-post"
                phx-value-id={@post.post_id}
                class="bg-gray-800 hover:bg-gray-700 text-indigo-300 px-2 py-1 rounded text-xs border border-gray-700 transition-colors"
              >
                Quote
              </button>
            </div>
          </div>

          <div class="text-gray-100 text-sm whitespace-pre-wrap leading-relaxed">
            {(@post.post_text && raw(@post.post_text.post_text)) || "[No content]"}
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp parse_int(val, default \\ 0)
  defp parse_int(val, _default) when is_integer(val), do: val

  defp parse_int(val, default) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_int(_, default), do: default

  defp format_timestamp(nil), do: ""

  defp format_timestamp(unix_timestamp) when is_integer(unix_timestamp) and unix_timestamp > 0 do
    unix_timestamp
    |> DateTime.from_unix!()
    |> Calendar.strftime("%b %d, %Y, %I:%M %p")
  end

  defp format_timestamp(_), do: ""
end
