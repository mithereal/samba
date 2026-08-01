defmodule SambaWeb.OnlineUsersLive do
  use SambaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      SambaWeb.Endpoint.subscribe("online_users")
      :timer.send_interval(30_000, self(), :tick)
    end

    {:ok, assign_users(socket)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign_users(socket)}
  end

  @impl true
  def handle_info({:presence_update, _presence_data}, socket) do
    {:noreply, assign_users(socket)}
  end

  defp assign_users(socket) do
    registered_users = [
      %{
        id: 1,
        username: "Alice",
        profile_path: ~p"/user/alice",
        last_updated: ~N[2026-07-26 14:50:00],
        location: "General Discussion",
        location_path: ~p"/forum/general"
      },
      %{
        id: 2,
        username: "Bob",
        profile_path: ~p"/user/bob",
        last_updated: ~N[2026-07-26 14:48:20],
        location: "Elixir & Phoenix",
        location_path: ~p"/forum/elixir"
      }
    ]

    guests = [
      %{
        id: 101,
        username: "Guest_4892",
        profile_path: nil,
        last_updated: ~N[2026-07-26 14:49:10],
        location: "FAQ",
        location_path: ~p"/forum/faq"
      },
      %{
        id: 102,
        username: "Guest_1102",
        profile_path: nil,
        last_updated: ~N[2026-07-26 14:51:00],
        location: "Home Page",
        location_path: ~p"/"
      }
    ]

    assign(socket,
      registered_users: sort_by_last_updated(registered_users),
      guests: sort_by_last_updated(guests)
    )
  end

  defp sort_by_last_updated(users) do
    Enum.sort_by(users, & &1.last_updated, {:desc, NaiveDateTime})
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <div class="mt-4 max-w-8xl mx-auto p-4 bg-white dark:bg-zinc-900 text-zinc-900 dark:text-zinc-100 shadow-md rounded-lg border border-zinc-200 dark:border-zinc-800 transition-colors">
      <h2 class="text-xl font-bold mb-4">Who's Online</h2>

      <!-- Registered Users Section -->
      <div class="mb-6">
        <h3 class="text-md font-semibold text-zinc-700 dark:text-zinc-300 mb-3">
          Registered Users ({length(@registered_users)})
        </h3>

        <.user_list users={@registered_users} type="registered" />
      </div>

      <!-- Separator Bar -->
      <div class="relative flex py-2 items-center">
        <div class="flex-grow border-t border-zinc-200 dark:border-zinc-700"></div>
        <span class="flex-shrink mx-4 text-zinc-400 dark:text-zinc-500 text-sm uppercase tracking-wider font-medium">Guests</span>
        <div class="flex-grow border-t border-zinc-200 dark:border-zinc-700"></div>
      </div>

      <!-- Guests Section -->
      <div class="mt-6">
        <h3 class="text-md font-semibold text-zinc-700 dark:text-zinc-300 mb-3">
          Guests ({length(@guests)})
        </h3>

        <.user_list users={@guests} type="guest" />
      </div>
    </div>
    """
  end

  defp user_list(assigns) do
    ~H"""
    <div class="rounded-md border border-zinc-200 dark:border-zinc-700 overflow-hidden text-sm">
      <!-- Flexbox Header -->
      <div class="flex bg-zinc-50 dark:bg-zinc-800 px-6 py-3 border-b border-zinc-200 dark:border-zinc-700 font-medium text-zinc-500 dark:text-zinc-400 uppercase tracking-wider">
        <div class="w-1/3">Username</div>
        <div class="w-1/3">Last Updated</div>
        <div class="w-1/3">Forum Location</div>
      </div>

      <!-- Flexbox Body -->
      <div class="bg-white dark:bg-zinc-900 divide-y divide-zinc-200 dark:divide-zinc-700">
        <%= if Enum.empty?(@users) do %>
          <div class="px-6 py-4 text-center text-zinc-400 dark:text-zinc-500 italic">
            No {@type} currently online.
          </div>
        <% else %>
          <%= for user <- @users do %>
            <div class="flex items-center px-6 py-4 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
              <div class="w-1/3 font-medium text-zinc-900 dark:text-zinc-100">
                <%= if user.id do %>
                  <.link
                    navigate={"/profile/#{user.id}"}
                    class="hover:underline text-indigo-600 dark:text-indigo-400"
                  >
                    {user.username}
                  </.link>
                <% else %>
                  <span class="text-zinc-500 dark:text-zinc-400">{user.username}</span>
                <% end %>
              </div>
              <div class="w-1/3 text-zinc-500 dark:text-zinc-400">
                {format_time(user.last_updated)}
              </div>
              <div class="w-1/3">
                <.link
                  navigate={user.location_path}
                  class="hover:underline text-indigo-600 dark:text-indigo-400"
                >
                  {user.location}
                </.link>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp format_time(naive_datetime) do
    Calendar.strftime(naive_datetime, "%I:%M %p")
  end
end
