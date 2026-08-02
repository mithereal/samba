defmodule SambaWeb.OnlineUsersLive do
  use SambaWeb, :live_view
  use SambaWeb.LiveTracking
  @impl true

  def page_name() do
    "Online Users"
  end

  def page_url() do
    "/viewonline"
  end

  def mount(_params, _session, socket) do
    # online_users = []
    phpbb_online_users = []
    guest_users = []
    online_users = list_registered_users()
    {:ok, phpbb_online_users} = get_phpbb_users(online_users)
    guest_users = list_guest_users()
    guest_users = marshall_guest_users(guest_users)

    socket =
      socket
      |> assign(:page_title, "Online Users")
      |> assign(:registered_users, phpbb_online_users)
      |> assign(:guests, guest_users)

    {:ok, socket}
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
                <span class="text-zinc-500 dark:text-zinc-400">{user.username}</span>
              </div>
              <div class="w-1/3 text-zinc-500 dark:text-zinc-400">
                <span class="text-zinc-500 dark:text-zinc-400">{format_timestamp(user.online_at)}</span>
              </div>
              <div class="w-1/3">
                <span class="text-zinc-500 dark:text-zinc-400"><.link navigate={user.location.link}>{user.location.page_name}</.link></span>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  import Ash.Query

  defp get_phpbb_users(presence_list) do
    import Ash.Query

    account_user_ids =
      presence_list
      |> Enum.map(fn {user_id, _meta} ->
        user_id
      end)
      |> Enum.reject(&is_nil/1)

    case Samba.Accounts.User
         |> filter(id in ^account_user_ids)
         |> select([:id, :phpbb_user_id])
         |> Ash.read(authorize?: false) do
      {:ok, accounts} ->
        account_to_phpbb = Map.new(accounts, fn acc -> {to_string(acc.id), acc.phpbb_user_id} end)
        phpbb_ids = accounts |> Enum.map(& &1.phpbb_user_id) |> Enum.reject(&is_nil/1)

        if Enum.empty?(phpbb_ids) do
          result =
            Enum.map(presence_list, fn {user_id, meta} ->
              Map.merge(sanitize_meta(meta), %{phpbb: nil})
            end)

          {:ok, result}
        else
          case PhpBB.Users
               |> filter(user_id in ^phpbb_ids)
               |> select([:user_id, :username, :user_rank, :user_allow_viewonline])
               |> Ash.read(domain: PhpBB.Domain, authorize?: false) do
            {:ok, phpbb_users} ->
              phpbb_users_map = Map.new(phpbb_users, fn u -> {u.user_id, u} end)

              result =
                Enum.map(presence_list, fn {user_id, meta} ->
                  sanitized_meta = List.first(sanitize_meta(meta).metas)
                  phpbb_id = Map.get(account_to_phpbb, user_id)
                  phpbb_user = phpbb_id && Map.get(phpbb_users_map, phpbb_id)

                  %{
                    id: phpbb_user.user_id,
                    username: phpbb_user.username,
                    role: phpbb_user.user_rank,
                    visible: phpbb_user.user_allow_viewonline,
                    location: %{
                      page_name: sanitized_meta.page_name,
                      link: sanitized_meta.location
                    },
                    online_at: sanitized_meta.online_at
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

  def marshall_guest_users(users) do
    Enum.flat_map(users, fn
      {_, %{metas: metas}} when is_list(metas) ->
        Enum.map(metas, fn meta ->
          %{
            username: "guest",
            location: %{page_name: Map.get(meta, :page_name), link: Map.get(meta, :location)},
            online_at: Map.get(meta, :online_at)
          }
        end)

      {_, %{metas: metas}} when is_map(metas) ->
        [
          %{
            username: "guest",
            location: %{page_name: Map.get(metas, :page_name), link: Map.get(metas, :location)},
            online_at: Map.get(metas, :online_at)
          }
        ]

      {_, path} when is_binary(path) ->
        [
          %{
            username: "guest",
            location: %{page_name: "Private Area", link: "/"},
            online_at: DateTime.utc_now()
          }
        ]

      _ ->
        []
    end)
  end
end
