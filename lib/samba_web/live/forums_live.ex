defmodule SambaWeb.ForumIndexLive do
  use SambaWeb, :live_view
  use SambaWeb.LiveTracking

  def mount(_params, _session, socket) do
    categories =
      PhpBB.Categories
      |> Ash.Query.sort(cat_order: :asc)
      |> Ash.Query.load(
        forums: [
          :forum_topics,
          :forum_posts,
          last_post: [poster: []]
        ]
      )
      |> Ash.read!(domain: PhpBB.Domain)

    online_users = list_forum_online_users()
    {:ok, phpbb_online_users} = get_phpbb_users_by_account_ids(online_users)

    guest_users = list_guest_users()
    chat_users = list_chat_users()

    hidden_users = Enum.filter(phpbb_online_users, fn u -> u.visible == 0 end)

    peak_stat =
      Samba.Analytics.DailyStat
      |> Ash.Query.for_read(:max_online)
      |> Ash.read_one!(domain: Samba.Analytics)

    peak_users =
      if peak_stat do
        peak_stat.total_online
      else
        "No data available"
      end

    formatted_peak =
      if peak_stat do
        Calendar.strftime(peak_stat.recorded_at, "%a %b %d, %Y %I:%M %p")
      else
        "No data available"
      end

    stats = %{
      total_online: Enum.count(list_online_users()),
      registered_count: Enum.count(phpbb_online_users),
      hidden_count: Enum.count(hidden_users),
      guest_count: Enum.count(guest_users),
      max_online: peak_users,
      max_online_date: formatted_peak,
      chat_users: Enum.count(chat_users)
    }

    socket =
      socket
      |> assign(:page_title, "Forums")
      |> assign(:categories, categories)
      |> assign(:phpbb_online_users, phpbb_online_users)
      |> assign(:stats, stats)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <div class="w-full mx-auto px-4 sm:px-6 lg:px-4 py-8 text-gray-900 dark:text-gray-100">
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900/80 backdrop-blur-md">
        <!-- Table Header (Hidden on small screens) -->
        <div class="hidden md:grid md:grid-cols-12 bg-gray-200 dark:bg-gray-800 text-gray-700 dark:text-gray-300 font-semibold text-sm px-6 py-3 border-b border-gray-300 dark:border-gray-700 uppercase tracking-wider">
          <div class="col-span-6">Forum</div>
          <div class="col-span-2 text-center">Topics</div>
          <div class="col-span-2 text-center">Posts</div>
          <div class="col-span-2 text-right">Last Post</div>
        </div>

        <!-- Forum Categories & List -->
        <div class="divide-y divide-gray-200 dark:divide-gray-800">
          <%= for category <- @categories do %>
            <!-- Category Heading (SubSilver Style Differentiation) -->
            <div class="bg-gray-100 dark:bg-gray-800/90 text-gray-700 dark:text-gray-200 font-bold px-6 py-2.5 text-sm uppercase tracking-wide border-t border-b border-gray-300 dark:border-gray-700">
              {category.cat_title}
            </div>

            <%= for forum <- category.forums do %>
              <!-- Forum Item -->
              <div class="bg-white hover:bg-gray-50 dark:bg-gray-900 dark:hover:bg-gray-800/40 grid grid-cols-1 md:grid-cols-12 px-6 py-4 transition-colors items-center gap-4 md:gap-0">
                <!-- Forum Name, Description & Status Icon -->
                <div class="col-span-6 flex items-start space-x-3">
                  <div class="flex-shrink-0 mt-1">
                    <%= cond do %>
                      <% forum.forum_status == 1 -> %>
                        <span
                          class="inline-flex items-center justify-center w-10 h-10 rounded-lg bg-red-100 dark:bg-red-900/50 text-red-600 dark:text-red-400"
                          title="Forum Locked"
                        >
                          <.icon name="hero-lock-closed" class="w-6 h-6" />
                        </span>
                      <% is_nil(forum.last_post) -> %>
                        <span
                          class="inline-flex items-center justify-center w-10 h-10 rounded-lg bg-gray-200 dark:bg-gray-800 text-gray-500"
                          title="No Posts"
                        >
                          <.icon name="hero-folder" class="w-6 h-6" />
                        </span>
                      <% true -> %>
                        <span
                          class="inline-flex items-center justify-center w-10 h-10 rounded-lg bg-blue-100 dark:bg-blue-900/50 text-blue-600 dark:text-blue-400"
                          title="New Posts"
                        >
                          <.icon name="hero-folder-open" class="w-6 h-6" />
                        </span>
                    <% end %>
                  </div>
                  <div>
                    <.link
                      navigate={~p"/forums/#{forum.forum_id}"}
                      class="text-base font-semibold text-gray-900 dark:text-gray-100 hover:text-indigo-600 dark:hover:text-indigo-400"
                    >
                      {forum.forum_name}
                    </.link>
                    <p class="text-sm text-gray-500 dark:text-gray-400">{forum.forum_desc}</p>
                  </div>
                </div>

                <!-- Topics Count -->
                <div class="col-span-2 text-left md:text-center text-sm text-gray-600 dark:text-gray-300 flex md:block justify-between">
                  <span class="md:hidden font-medium text-gray-500 dark:text-gray-400">Topics:</span>
                  <span>{length(forum.forum_topics || [])}</span>
                </div>

                <!-- Posts Count -->
                <div class="col-span-2 text-left md:text-center text-sm text-gray-600 dark:text-gray-300 flex md:block justify-between">
                  <span class="md:hidden font-medium text-gray-500 dark:text-gray-400">Posts:</span>
                  <span>{length(forum.forum_posts || [])}</span>
                </div>

                <!-- Last Post Info -->
                <div class="col-span-2 text-left md:text-right text-xs text-gray-500 dark:text-gray-400">
                  <%= if forum.last_post do %>
                    <div class="font-medium text-gray-800 dark:text-gray-200 truncate max-w-[200px] md:max-w-none">
                      <.link
                        navigate={~p"/topic/post/#{forum.last_post.post_id}"}
                        class="hover:underline"
                      >
                        {Map.get(forum.last_post, :subject, "View Post")}
                      </.link>
                    </div>
                    <div class="text-gray-500 dark:text-gray-400 mt-0.5">
                      by
                      <.link
                        navigate={"/profile/#{forum.last_post.poster.user_id}"}
                        class="hover:underline"
                      ><span class="text-gray-700 dark:text-gray-300 font-medium">{forum.last_post.poster.username}</span></.link>
                      <span class="mx-1 text-gray-400 dark:text-gray-600">&raquo;</span>
                      <span>{format_timestamp(forum.last_post.post_time)}</span>
                    </div>
                  <% else %>
                    <span class="text-gray-400 dark:text-gray-500 italic">No posts</span>
                  <% end %>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
        <.whos_online current_user={@current_user} stats={@stats} users={@phpbb_online_users} />
        <!-- Centered Legend Footer -->
        <div class="bg-gray-100 dark:bg-gray-800/80 px-6 py-4 border-t border-gray-300 dark:border-gray-700 flex flex-wrap items-center justify-center gap-6 text-xs text-gray-700 dark:text-gray-300">
          <div class="flex items-center space-x-2">
            <span class="inline-flex items-center justify-center w-6 h-6 rounded bg-blue-100 dark:bg-blue-900/50 text-blue-600 dark:text-blue-400">
              <.icon name="hero-folder-open" class="w-4 h-4" />
            </span>
            <span>New Posts</span>
          </div>
          <div class="flex items-center space-x-2">
            <span class="inline-flex items-center justify-center w-6 h-6 rounded bg-gray-200 dark:bg-gray-800 text-gray-600 dark:text-gray-500">
              <.icon name="hero-folder" class="w-4 h-4" />
            </span>
            <span>No Posts</span>
          </div>

          <div class="flex items-center space-x-2">
            <span class="inline-flex items-center justify-center w-6 h-6 rounded bg-red-100 dark:bg-red-900/50 text-red-600 dark:text-red-400">
              <.icon name="hero-lock-closed" class="w-4 h-4" />
            </span>
            <span>Forum Locked</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  import Ash.Query

  def get_phpbb_users_by_account_ids(account_user_ids) do
    case Samba.Accounts.User
         |> filter(id in ^account_user_ids)
         |> select([:id, :phpbb_user_id])
         |> Ash.read(authorize?: false) do
      {:ok, accounts} ->
        phpbb_ids = Enum.map(accounts, & &1.phpbb_user_id) |> Enum.reject(&is_nil/1)

        if Enum.empty?(phpbb_ids) do
          {:ok, []}
        else
          case PhpBB.Users
               |> filter(user_id in ^phpbb_ids)
               |> select([:user_id, :username, :user_rank, :user_allow_viewonline])
               |> Ash.read(domain: PhpBB.Domain, authorize?: false) do
            {:ok, phpbb_users} ->
              result =
                Enum.map(phpbb_users, fn u ->
                  %{
                    id: u.user_id,
                    username: u.username,
                    role: u.user_rank,
                    visible: u.user_allow_viewonline
                  }
                end)

              {:ok, result}

            {:error, reason} ->
              {:error, reason}
          end
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
