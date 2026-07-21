defmodule SambaWeb.LandingLive do
  use SambaWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <!-- Main Content Grid -->
    <main class="flex pt-4 gap-4">
      <!-- Sidebar Left -->
      <aside class="space-y-4">
        <div class="bg-gray-200 pl-2 text-xs font-bold border h-[90px] border">
          What's New <span class="ml-4 pr-2">July 19, 2026</span>
        </div>
        <div class="bg-gray-200 pl-2 text-xs font-bold border h-[90px] border">Scam Warnings</div>
        <div class="bg-gray-200 pl-2 text-xs font-bold border h-[90px] border">Log-in</div>
        <div class="bg-gray-200 pl-2 text-xs font-bold border h-[90px] border">Search</div>
        <div class="bg-gray-200 pl-2 text-xs font-bold border h-[90px] border">Classifieds</div>
        <div class="bg-gray-200 pl-2 text-xs font-bold border h-[90px] border">Gallery</div>
        <!-- Repeat for other sidebar widgets -->
      </aside>

      <!-- Main Content Middle -->
      <section class="mx-auto min-h-[70vh] grow">
        <div class="bg-gray-200 pl-2 text-xs font-bold border">Facts</div>
        <div class="bg-gray-200 pl-2 text-xs font-bold border">Featured Ads</div>
      </section>

      <!-- Sidebar Right -->
      <aside class="space-y-4">
        <div class="bg-gray-200 p-2 font-bold border">
          <div class="">Advertisement</div>
          <div class="animate-marquee">
            Advertisement Data
          </div>
        </div>
        <div class="h-[90px] border">
          <div class="">Stolen</div>
          <div class="animate-marquee">
            Stolen Data
          </div>
        </div>
        <div class="overflow-hidden whitespace-nowrap">
          <div class="animate-marquee">
            Events Data
          </div>
        </div>
      </aside>
    </main>
    """
  end
end
