defmodule SambaWeb.ForumIndexLive do
  use SambaWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    topic_id = String.to_integer(id)

    # Fetch the topic to get its associated forum_id if needed
    topic = Ash.get!(PhpBB.Topics, topic_id)

    preset = Preset.Parser.parse!(%{
      config: %{
        licenseKey: "GPL",
        toolbar: [:bold, :italic, :link],
        plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
      }
    })

    form =
      PhpBB.Posts
      |> AshPhoenix.Form.for_create(:create, as: "form",
           params: %{
             "topic_id" => topic_id,
             "forum_id" => topic.forum_id,
             "post_time" => System.os_time(:second)
           }
         )
      |> to_form()

    socket =
      socket
      |> assign(:topic_id, topic_id)
      |> assign(:forum_id, topic.forum_id)
      |> assign(:page_title, "Forums")
      |> assign(:preset, preset)
      |> assign(:form, form)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
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
              <%= category.cat_title %>
            </div>

            <%= for forum <- category.forums do %>
              <!-- Forum Item -->
              <div class="bg-white hover:bg-gray-50 dark:bg-gray-900 dark:hover:bg-gray-800/40 grid grid-cols-1 md:grid-cols-12 px-6 py-4 transition-colors items-center gap-4 md:gap-0">

                <!-- Forum Name, Description & Status Icon -->
                <div class="col-span-6 flex items-start space-x-3">
                  <div class="flex-shrink-0 mt-1">
                    <%= cond do %>
                      <% forum.forum_status == 1 -> %>
                        <span class="inline-flex items-center justify-center w-10 h-10 rounded-lg bg-red-100 dark:bg-red-900/50 text-red-600 dark:text-red-400" title="Forum Locked">
                          <.icon name="hero-lock-closed" class="w-6 h-6" />
                        </span>
                      <% is_nil(forum.last_post) -> %>
                        <span class="inline-flex items-center justify-center w-10 h-10 rounded-lg bg-gray-200 dark:bg-gray-800 text-gray-500" title="No Posts">
                          <.icon name="hero-folder" class="w-6 h-6" />
                        </span>
                      <% true -> %>
                        <span class="inline-flex items-center justify-center w-10 h-10 rounded-lg bg-blue-100 dark:bg-blue-900/50 text-blue-600 dark:text-blue-400" title="New Posts">
                          <.icon name="hero-folder-open" class="w-6 h-6" />
                        </span>
                    <% end %>
                  </div>
                  <div>
                    <.link navigate={~p"/forum/#{forum.forum_id}"} class="text-base font-semibold text-gray-900 dark:text-gray-100 hover:text-indigo-600 dark:hover:text-indigo-400">
                      <%= forum.forum_name %>
                    </.link>
                    <p class="text-sm text-gray-500 dark:text-gray-400"><%= forum.forum_desc %></p>
                  </div>
                </div>

                <!-- Topics Count -->
                <div class="col-span-2 text-left md:text-center text-sm text-gray-600 dark:text-gray-300 flex md:block justify-between">
                  <span class="md:hidden font-medium text-gray-500 dark:text-gray-400">Topics:</span>
                  <span><%= forum.forum_topics || 0 %></span>
                </div>

                <!-- Posts Count -->
                <div class="col-span-2 text-left md:text-center text-sm text-gray-600 dark:text-gray-300 flex md:block justify-between">
                  <span class="md:hidden font-medium text-gray-500 dark:text-gray-400">Posts:</span>
                  <span><%= forum.forum_posts || 0 %></span>
                </div>

                <!-- Last Post Info -->
                <div class="col-span-2 text-left md:text-right text-xs text-gray-500 dark:text-gray-400">
                  <%= if forum.last_post do %>
                    <div class="font-medium text-gray-800 dark:text-gray-200 truncate max-w-[200px] md:max-w-none">
                      <.link navigate={~p"/topic/post/#{forum.last_post.post_id}"} class="hover:underline">
                        <%= get_in(forum.last_post, [:post_text, :post_subject]) || "View Post" %>
                      </.link>
                    </div>
                    <div class="text-gray-500 dark:text-gray-400 mt-0.5">
                      <%= if forum.last_post.poster do %>
                        by <.link navigate={"/profile/#{forum.last_post.poster.user_id}"} class="hover:underline"><span class="text-gray-700 dark:text-gray-300 font-medium"><%= forum.last_post.poster.username %></span></.link>
                      <% else %>
                        by Guest
                      <% end %>
                      <span class="mx-1 text-gray-400 dark:text-gray-600">&raquo;</span>
                      <span><%= format_timestamp(forum.last_post.post_time) %></span>
                    </div>
                  <% else %>
                    <span class="text-gray-400 dark:text-gray-500 italic">No posts</span>
                  <% end %>
                </div>

              </div>
            <% end %>
          <% end %>
        </div>

        <.whos_online />

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

  defp format_timestamp(nil), do: ""
  defp format_timestamp(unix_timestamp) when is_integer(unix_timestamp) and unix_timestamp > 0 do
    post_dt = DateTime.from_unix!(unix_timestamp)
    post_date = DateTime.to_date(post_dt)
    today = Date.utc_today()

    day_name = Calendar.strftime(post_dt, "%a") |> String.downcase()
    time_str = Calendar.strftime(post_dt, "%I:%M %p") |> String.downcase()

    cond do
      post_date == today ->
        "#{day_name}, today #{time_str}"

      post_date == Date.add(today, -1) ->
        "#{day_name}, yesterday #{time_str}"

      true ->
        date_str = Calendar.strftime(post_dt, "%b %d") |> String.downcase()
        "#{day_name}, #{date_str}, #{time_str}"
    end
  end
  defp format_timestamp(_), do: ""
end