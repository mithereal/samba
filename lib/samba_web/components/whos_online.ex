defmodule SambaWeb.Components.WhosOnline do
  use Phoenix.Component
  use SambaWeb, :verified_routes
  import SambaWeb.Components.Icon

  attr :stats, :map,
    default: %{
      total_online: "15,281",
      registered_count: 37,
      hidden_count: 5,
      guest_count: "15,239",
      max_online: "76,159",
      max_online_date: "Sat Jan 24, 2026 12:23 am",
      chat_users: 1
    }

  attr :users, :list,
    default: [
      %{id: 236_365, username: "50COUPE'", role: :member},
      %{id: 139_910, username: "77kafer", role: :member},
      %{id: 413_034, username: "Angus II", role: :member},
      %{id: 59771, username: "bavarian1", role: :member},
      %{id: 26064, username: "BulliBill", role: :member},
      %{id: 62836, username: "dave clifford", role: :member},
      %{id: 392_686, username: "dogballs666", role: :member},
      %{id: 30866, username: "Eric&Barb", role: :member},
      %{id: 42771, username: "fadler1", role: :member},
      %{id: 375_649, username: "fxr", role: :member},
      %{id: 158_664, username: "Graysvws", role: :member},
      %{id: 424_038, username: "heimlich", role: :admin},
      %{id: 514_841, username: "hobthebob", role: :member},
      %{id: 361_857, username: "jaconty", role: :member},
      %{id: 9242, username: "jim", role: :admin},
      %{id: 534_515, username: "jim coe", role: :member},
      %{id: 562_882, username: "LUZIE", role: :member},
      %{id: 560_250, username: "Mark stacey", role: :member},
      %{id: 449_379, username: "mfw59", role: :member},
      %{id: 379_128, username: "Mr. Mike", role: :member},
      %{id: 19131, username: "nathan3", role: :member},
      %{id: 117_785, username: "NJ John", role: :member},
      %{id: 513_324, username: "penalosap", role: :member},
      %{id: 218_828, username: "Q-Dog", role: :member},
      %{id: 322_628, username: "Racer Rick", role: :member},
      %{id: 300_442, username: "rhd914", role: :member},
      %{id: 19710, username: "RJ'sVW", role: :member},
      %{id: 60271, username: "rorrerhow", role: :member},
      %{id: 9965, username: "stevo", role: :member},
      %{id: 539_786, username: "Tapsr1", role: :member},
      %{id: 337_723, username: "TDCTDI", role: :member},
      %{id: 115_578, username: "The Cheetle", role: :member},
      %{id: 529_457, username: "titolillas", role: :member},
      %{id: 26966, username: "Transportation Emporium", role: :admin},
      %{id: 206_842, username: "uncleblue99", role: :member},
      %{id: 116_281, username: "VWSTORECHICK", role: :member},
      %{id: 6393, username: "Walk Thru KO", role: :member}
    ]

  def whos_online(assigns) do
    ~H"""
    <div class="w-full mx-auto shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900/80 backdrop-blur-md">
      <!-- Header -->
      <div class="bg-gray-100 dark:bg-gray-800/90 text-gray-700 dark:text-gray-200 font-bold px-6 py-2.5 text-sm uppercase tracking-wide border-b border-gray-300 dark:border-gray-700">
        <.link navigate={~p"/viewonline"} class="hover:underline">Who is Online</.link>
      </div>

      <!-- Content Area -->
      <div class="p-6 flex flex-col md:flex-row items-start md:items-center gap-6 text-sm text-gray-700 dark:text-gray-300">
        <!-- Icon / Image section -->
        <div class="flex-shrink-0 self-center md:self-start">
          <div class="w-12 h-12 rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center text-indigo-500">
            <.icon name="hero-users" class="w-7 h-7" />
          </div>
        </div>

        <!-- Stats & Users Details -->
        <div class="flex-grow space-y-3 text-xs md:text-sm">
          <div>
            In total there are <span class="font-bold">{@stats.total_online}</span>
            users online :: {@stats.registered_count} Registered, {@stats.hidden_count} Hidden and {@stats.guest_count} Guests<br />
            Most users ever online was <span class="font-bold">{@stats.max_online}</span>
            on {@stats.max_online_date}
          </div>

          <div>
            <span class="font-semibold">Registered Users:</span>
            <span class="text-gray-600 dark:text-gray-400 leading-relaxed">
              <%= for {user, index} <- Enum.with_index(@users) do %>
                <.link
                  navigate={~p"/profile/#{user.id}"}
                  class={[
                    "hover:underline",
                    user.role in [:admin, :super_mod] &&
                      "font-bold text-indigo-600 dark:text-indigo-400"
                  ]}
                ><%= user.username %></.link>{if index < length(@users) - 1, do: ", "}
              <% end %>
            </span>
          </div>

          <div class="text-gray-500 dark:text-gray-400 pt-1 border-t border-gray-200 dark:border-gray-800 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
            <span>There are
            <span class="font-bold text-gray-700 dark:text-gray-200">{@stats.chat_users}</span>
            users in chat right now. &nbsp;[ Please login to use chat ]</span>
            <span class="italic text-gray-400 dark:text-gray-500">Data based on users active over past 5 minutes</span>
          </div>
        </div>
      </div>

      <!-- Role Legend Footer -->
      <div class="bg-gray-100 dark:bg-gray-800/80 px-6 py-3 border-t border-gray-300 dark:border-gray-700 text-xs flex flex-wrap items-center justify-center gap-4 text-gray-600 dark:text-gray-300">
        <span class="font-bold">Legend:</span>
        <span class="font-semibold" style="color: #C97B01;">Administrator</span>
        <span class="font-semibold" style="color: #C0C000;">Super Moderator</span>
        <span class="font-semibold" style="color: #008000;">Moderator</span>
        <span class="font-semibold" style="color: #9E8DA7;">Bot</span>
        <.link
          navigate={~p"/premium_membership"}
          class="font-semibold underline text-indigo-600 dark:text-indigo-400"
        >Premium Member</.link>
      </div>
    </div>
    """
  end
end
