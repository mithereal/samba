defmodule SambaWeb.MemberListLive do
  use SambaWeb, :live_view
  use SambaWeb.LiveTracking

  def mount(_params, _session, socket) do
    members =
      PhpBB.Users
      |> Ash.read!(domain: PhpBB.Domain)

    socket =
      socket
      |> assign(:page_title, "Memberlist")
      |> assign(:members, members)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <div class="w-full mx-auto px-4 sm:px-6 lg:px-4 py-8 text-gray-900 dark:text-gray-100">
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900/80 backdrop-blur-md">
      </div>
    </div>
    """
  end
end
