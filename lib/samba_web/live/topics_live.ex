defmodule SambaWeb.ForumTopicsLive do
  use SambaWeb, :live_view
  use SambaWeb.LiveTracking
  require Ash.Query

  def mount(%{"id" => forum_id} = params, _session, socket) do
    forum_id = parse_int(forum_id)
    page = parse_int(params["page"], 1)
    per_page = parse_int(params["per_page"], 25)
    offset_val = (page - 1) * per_page

    forum =
      PhpBB.Forums
      |> Ash.Query.filter(forum_id == ^forum_id)
      |> Ash.read_one!(domain: PhpBB.Domain)

    # Fetch groups with moderator access for this forum, then load their moderator user record
    moderators =
      PhpBB.AuthAccess
      |> Ash.Query.filter(forum_id == ^forum_id)
      |> Ash.Query.load(group: [:moderator])
      |> Ash.read!(domain: PhpBB.Domain)
      |> Enum.map(fn access ->
        access.group && access.group.moderator && access.group.moderator.username
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.sort()

    sticky_topics =
      PhpBB.Topics
      |> Ash.Query.filter(forum_id == ^forum_id and topic_type == 1)
      |> Ash.Query.sort(topic_time: :desc)
      |> Ash.Query.load([:poster, :last_post])
      |> Ash.read!(domain: PhpBB.Domain)

    paginated_query =
      PhpBB.Topics
      |> Ash.Query.filter(forum_id == ^forum_id and topic_type != 1)
      |> Ash.Query.sort(topic_time: :desc)
      |> Ash.Query.load([:poster, :last_post])
      |> Ash.Query.page(limit: per_page, offset: offset_val)

    page_results = Ash.read!(paginated_query, domain: PhpBB.Domain)

    socket =
      socket
      |> assign(:page_title, (forum && forum.forum_name) || "Topics")
      |> assign(:forum, forum)
      |> assign(:moderators, moderators)
      |> assign(:sticky_topics, sticky_topics || [])
      |> assign(:topics, page_results.results || [])
      |> assign(:page, page)
      |> assign(:per_page, per_page)
      |> assign(:more?, page_results.more?)
      |> assign(:forum_id, forum_id)

    {:ok, socket}
  end

  def handle_event("change-per-page", %{"per_page" => per_page}, socket) do
    {:noreply,
     push_navigate(socket, to: ~p"/forums/#{socket.assigns.forum_id}?page=1&per_page=#{per_page}")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <div class="w-full mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
      <!-- Breadcrumb & Header Action -->
      <div class="flex justify-between ">
        <div class="mb-2 flex justify-end flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-black">
              {@forum && @forum.forum_name}
            </h1>
            <p class="text-sm text-gray-400">Moderators: {Enum.join(@moderators, ", ")}</p>
            <.breadcrumb>
              <:item icon="hero-folder" link="/forums">Forum Index</:item>
              <:item icon="hero-folder-open">
                {@forum && @forum.forum_name}
              </:item>
            </.breadcrumb>
            <p class="mt-5 text-sm text-black">{@forum && raw(@forum.forum_desc)}</p>
            <.link
              navigate={~p"/forum/#{@forum_id}/topic/new"}
              class="inline-flex items-center px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-semibold rounded-md shadow transition-colors"
            >
              Post New Topic
            </.link>
            <.form_wrapper for={assigns[:search_form]} method="get" action={~p"/search"}>
              <.search_field
                name="q"
                value=""
                placeholder=""
                search_button
                class="text-xs"
                size="extra-small"
              />
            </.form_wrapper>
          </div>
        </div>
        <div class="text-black flex flex-col justify-end text-right mr-4 ">
          <.link
            navigate={~p"/forums/#{@forum_id}/mark_topics"}
            class="inline-flex items-center px-4  text-gray-700  text-sm font-semibold rounded-md shadow transition-colors"
          >
            Mark all topics read
          </.link>
        </div>
      </div>
      <!-- Main subSilver Dark/Light Adaptive Table Container -->
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-700 bg-gray-900/80 backdrop-blur-md">
        <!-- Table Header -->
        <div class="hidden md:grid md:grid-cols-12 bg-gray-800 text-gray-300 font-semibold text-sm px-6 py-3 border-b border-gray-700 uppercase tracking-wider">
          <div class="col-span-6">Topics</div>
          <div class="col-span-1 text-center">Replies</div>
          <div class="col-span-2 text-center">Author</div>
          <div class="col-span-1 text-center">Views</div>
          <div class="col-span-2 text-right">Last Post</div>
        </div>

        <div class="divide-y divide-gray-800">
          <!-- Sticky Topics Section -->
          <%= if length(@sticky_topics) > 0 do %>
            <div class="bg-gray-800/90 text-amber-400 font-bold px-6 py-2 text-xs uppercase tracking-wider border-b border-gray-700 flex items-center space-x-2">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"
                />
              </svg>
              <span>Announcements & Sticky Topics</span>
            </div>

            <%= for topic <- @sticky_topics do %>
              <.topic_row topic={topic} is_sticky={true} />
            <% end %>
          <% end %>

          <!-- Standard Topics Section Header -->
          <div class="bg-gray-800/90 text-gray-200 font-bold px-6 py-2 text-xs uppercase tracking-wider border-b border-gray-700">
            Topics
          </div>

          <%= if length(@topics) == 0 do %>
            <div class="px-6 py-8 text-center text-gray-500 italic">
              No topics found in this forum.
            </div>
          <% else %>
            <%= for topic <- @topics do %>
              <.topic_row topic={topic} is_sticky={false} />
            <% end %>
          <% end %>
        </div>
      </div>

      <!-- Pagination & Legend Footer -->
      <div class="flex flex-col sm:flex-row items-center justify-between mt-6 px-2 gap-4">
        <!-- phpBB Icon Legend -->
        <div class="flex flex-wrap items-center gap-4 text-xs text-gray-400">
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full bg-indigo-400"></span> New posts
          </div>
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full bg-gray-500"></span> No new posts
          </div>
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full bg-amber-400"></span> Sticky
          </div>
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full bg-red-400"></span> Locked
          </div>
        </div>

        <!-- Navigation Buttons -->
        <div class="flex space-x-2">
          <%= if @page > 1 do %>
            <.link
              patch={~p"/forums/#{@forum_id}?page=#{@page - 1}&per_page=#{@per_page}"}
              class="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-md text-sm font-medium border border-gray-700 transition-colors"
            >
              &larr; Previous
            </.link>
          <% end %>

          <%= if @more? do %>
            <.link
              patch={~p"/forums/#{@forum_id}?page=#{@page + 1}&per_page=#{@per_page}"}
              class="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-200 rounded-md text-sm font-medium border border-gray-700 transition-colors"
            >
              Next &rarr;
            </.link>
          <% end %>
        </div>
        <form phx-change="change-per-page" class="inline">
          <span class="text-black">Topics per page:</span>
          <select
            name="per_page"
            class="bg-gray-800 border border-gray-700 text-white rounded px-2 py-1 text-sm focus:outline-none focus:border-indigo-500"
          >
            <%= for count <- [15, 25, 50, 75, 100] do %>
              <option value={count} selected={@per_page == count}>{count}</option>
            <% end %>
          </select>
        </form>
      </div>
    </div>
    """
  end

  defp topic_row(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-12 px-6 py-4 hover:bg-gray-800/40 transition-colors items-center gap-3 md:gap-0">
      <!-- Topic Title & Folder Icon -->
      <div class="col-span-6 flex items-start space-x-3">
        <div class="flex-shrink-0 mt-1">
          <%= cond do %>
            <% @topic.topic_status == 1 -> %>
              <!-- Locked Topic Icon -->
              <svg
                class="w-5 h-5 text-red-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                title="Locked"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            <% @is_sticky -> %>
              <!-- Sticky Topic Icon -->
              <svg
                class="w-5 h-5 text-amber-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                title="Sticky"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"
                />
              </svg>
            <% @topic.topic_type == 2 -> %>
              <!-- Announcement Icon -->
              <svg
                class="w-5 h-5 text-indigo-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                title="Announcement"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"
                />
              </svg>
            <% true -> %>
              <!-- Standard Folder Icon (New vs No New Posts could check session or read status if available) -->
              <svg
                class="w-5 h-5 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                title="No New Posts"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                />
              </svg>
          <% end %>
        </div>
        <div>
          <.link
            navigate={~p"/topic/#{@topic.topic_id}"}
            class="text-base font-semibold text-gray-100 hover:text-indigo-400"
          >
            {@topic.topic_title}
          </.link>
        </div>
      </div>

      <!-- Replies -->
      <div class="col-span-1 text-left md:text-center text-sm text-gray-300 flex md:block justify-between">
        <span class="md:hidden font-medium text-gray-400">Replies:</span>
        <span>{@topic.topic_replies}</span>
      </div>

      <!-- Author -->
      <div class="col-span-2 text-left md:text-center text-sm text-gray-300 flex md:block justify-between">
        <span class="md:hidden font-medium text-gray-400">Author:</span>
        <span class="text-indigo-300 font-medium">{(@topic.poster && @topic.poster.username) ||
          "Anonymous"}</span>
      </div>

      <!-- Views -->
      <div class="col-span-1 text-left md:text-center text-sm text-gray-300 flex md:block justify-between">
        <span class="md:hidden font-medium text-gray-400">Views:</span>
        <span>{@topic.topic_views}</span>
      </div>

      <!-- Last Post -->
      <div class="col-span-2 text-left md:text-right text-xs text-gray-400">
        <%= if @topic.last_post do %>
          <div class="font-medium text-gray-200 truncate max-w-[200px] md:max-w-none">
            <.link navigate={~p"/posts/#{@topic.last_post.post_id}"} class="hover:underline">
              {Map.get(@topic.last_post, :subject, "View Post")}
            </.link>
          </div>
          <div class="text-gray-400">
            <span>{format_timestamp(@topic.topic_time)}</span>
          </div>
        <% else %>
          <span class="text-gray-500 italic">No activity</span>
        <% end %>
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
end
