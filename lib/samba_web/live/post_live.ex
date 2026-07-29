defmodule SambaWeb.PostLive do
  use SambaWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Forums")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">

    </div>
    """
  end
end