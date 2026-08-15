defmodule SambaWeb.MemberListLive do
  use SambaWeb, :live_view
  use SambaWeb.LiveTracking

  on_mount {SambaWeb.LiveUserAuth, :live_user_required}
  def mount(_params, _session, socket) do
    users =
      PhpBB.Users
      |> Ash.read!(domain: PhpBB.Domain)

    socket =
      socket
      |> assign(:page_title, "Memberlist")
      |> assign(:users, users)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <div class="w-full overflow-hidden rounded-xl border border-zinc-200 bg-white shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
    <div class="overflow-x-auto">
    <table class="w-full text-left text-sm text-zinc-600 dark:text-zinc-400">
      <thead class="bg-zinc-50 text-xs uppercase tracking-wider text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300">
        <tr>
          <th scope="col" class="px-4 py-3 font-semibold">#</th>
          <th scope="col" class="px-4 py-3 font-semibold">PM</th>
          <th scope="col" class="px-4 py-3 font-semibold">Username</th>
          <th scope="col" class="px-4 py-3 font-semibold">Email</th>
          <th scope="col" class="px-4 py-3 font-semibold">Location</th>
          <th scope="col" class="px-4 py-3 font-semibold">Joined</th>
          <th scope="col" class="px-4 py-3 font-semibold">Status</th>
          <th scope="col" class="px-4 py-3 font-semibold">Last Visited</th>
          <th scope="col" class="px-4 py-3 font-semibold text-right">Posts</th>
          <th scope="col" class="px-4 py-3 font-semibold text-center">Website</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
        <%= for user <- @users do %>
          <tr class="transition-colors hover:bg-zinc-50/50 dark:hover:bg-zinc-800/50">
            <!-- # -->
            <td class="whitespace-nowrap px-4 py-3 font-medium text-zinc-900 dark:text-zinc-100">
              {user.user_id}
            </td>

            <!-- PM Action -->
            <td class="whitespace-nowrap px-4 py-3">
              <.link navigate={~p"/messages/new?to=#{user.user_id}"} class="inline-flex items-center gap-1.5 rounded-md bg-zinc-100 px-2.5 py-1.5 text-xs font-medium text-zinc-800 hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-200 dark:hover:bg-zinc-700">
                <.icon name="hero-chat-bubble-left-right" class="h-3.5 w-3.5" />
                <span>PM</span>
              </.link>
            </td>

            <!-- Username -->
            <td class="whitespace-nowrap px-4 py-3 font-medium text-zinc-900 dark:text-zinc-100">
              {user.username}
            </td>

            <!-- Email -->
            <td class="whitespace-nowrap px-4 py-3 text-zinc-500 dark:text-zinc-400">
              {user.user_email}
            </td>

            <!-- Location -->
            <td class="whitespace-nowrap px-4 py-3 text-zinc-500 dark:text-zinc-400">
              {user.user_from || "-"}
            </td>

            <!-- Joined Date (Unix timestamp to formatted date) -->
            <td class="whitespace-nowrap px-4 py-3 text-zinc-500 dark:text-zinc-400">
              {DateTime.from_unix!(user.user_regdate) |> Calendar.strftime("%b %d, %Y")}
            </td>

            <!-- Status Badge -->
            <td class="whitespace-nowrap px-4 py-3">
              <span class={[
                "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                user.user_active == 1 && "bg-emerald-50 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-400",
                user.user_active != 1 && "bg-zinc-100 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-400"
              ]}>
                {if user.user_active == 1, do: "Active", else: "Inactive"}
              </span>
            </td>

            <!-- Last Visited (Unix timestamp check) -->
            <td class="whitespace-nowrap px-4 py-3 text-zinc-500 dark:text-zinc-400">
              <%= if user.user_lastvisit > 0 do %>
                {DateTime.from_unix!(user.user_lastvisit) |> Calendar.strftime("%b %d, %Y %H:%M")}
              <% else %>
                Never
              <% end %>
            </td>

            <!-- Posts Count -->
            <td class="whitespace-nowrap px-4 py-3 text-right font-mono text-zinc-700 dark:text-zinc-300">
              {user.user_posts}
            </td>

            <!-- Website Link -->
            <td class="whitespace-nowrap px-4 py-3 text-center">
              <%= if user.user_website && user.user_website != "" do %>
                <a href={user.user_website} target="_blank" rel="noopener noreferrer" class="inline-text text-indigo-600 hover:text-indigo-800 dark:text-indigo-400 dark:hover:text-indigo-300">
                  <.icon name="hero-globe-alt" class="h-4 w-4 inline" />
                </a>
              <% else %>
                <span class="text-zinc-300 dark:text-zinc-700">-</span>
              <% end %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    </div>
    </div>
    """
  end
end