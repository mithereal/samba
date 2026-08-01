defmodule SambaWeb.MemberListLive do
  use SambaWeb, :live_view

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
