defmodule SambaWeb.ForumIndexLive do
  use SambaWeb, :live_view

  def mount(_params, _session, socket) do
    categories =
      PhpBB.Categories
      |> Ash.Query.sort(cat_order: :asc)
      |> Ash.Query.load([
        forums: [:topics, :posts, :lastpost]
      ])
      |> Ash.read!(domain: PhpBB.Domain)

    socket =
      socket
      |> assign(:page_title, "Forums")
      |> assign(:categories, categories)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-gray-100">
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-700 bg-gray-900/80 backdrop-blur-md">

        <!-- Table Header (Hidden on small screens) -->
        <div class="hidden md:grid md:grid-cols-12 bg-gray-800 text-gray-300 font-semibold text-sm px-6 py-3 border-b border-gray-700 uppercase tracking-wider">
          <div class="col-span-6">Forum</div>
          <div class="col-span-2 text-center">Topics</div>
          <div class="col-span-2 text-center">Posts</div>
          <div class="col-span-2 text-right">Last Post</div>
        </div>

        <!-- Forum Categories & List -->
        <div class="divide-y divide-gray-800">
          <%= for category <- @categories do %>
            <!-- Category Heading (SubSilver Style Differentiation) -->
            <div class="bg-gray-800/90 text-gray-200 font-bold px-6 py-2.5 text-sm uppercase tracking-wide border-t border-b border-gray-700">
              <%= category.cat_title %>
            </div>

            <%= for forum <- category.forums do %>
              <!-- Forum Item -->
              <div class="grid grid-cols-1 md:grid-cols-12 px-6 py-4 hover:bg-gray-800/40 transition-colors items-center gap-4 md:gap-0">
                <div class="col-span-6 flex items-start space-x-3">
                  <div class="flex-shrink-0 mt-1 text-indigo-400">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                    </svg>
                  </div>
                  <div>
                    <.link navigate={~p"/forums/#{forum.forum_id}"} class="text-base font-semibold text-gray-100 hover:text-indigo-400">
                      <%= forum.forum_name %>
                    </.link>
                    <p class="text-sm text-gray-400"><%= forum.forum_desc %></p>
                  </div>
                </div>

                <div class="col-span-2 text-left md:text-center text-sm text-gray-300 flex md:block justify-between">
                  <span class="md:hidden font-medium text-gray-400">Topics:</span>
                  <span><%= length(forum.topics || []) %></span>
                </div>

                <div class="col-span-2 text-left md:text-center text-sm text-gray-300 flex md:block justify-between">
                  <span class="md:hidden font-medium text-gray-400">Posts:</span>
                  <span><%= length(forum.posts || []) %></span>
                </div>

                <div class="col-span-2 text-left md:text-right text-xs text-gray-400">
                  <%= if forum.lastpost do %>
                    <div class="font-medium text-gray-200 truncate max-w-[200px] md:max-w-none">
                      <.link navigate={~p"/posts/#{forum.lastpost.post_id}"} class="hover:underline">
                        <%= Map.get(forum.lastpost, :subject, "View Post") %>
                      </.link>
                    </div>
                    <div class="text-gray-400">
                      by <span class="text-gray-300">User</span> · <span><%= format_timestamp(forum.lastpost.inserted_at) %></span>
                    </div>
                  <% else %>
                    <span class="text-gray-500 italic">No posts</span>
                  <% end %>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp format_timestamp(nil), do: ""
  defp format_timestamp(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y, %I:%M %p")
  end
end