defmodule SambaWeb.LandingLive do
  use SambaWeb, :live_view


  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div class="min-h-screen p-2 bg-gray-100 text-gray-900">
    <!-- Top Navigation Bar -->
    <nav class="bg-gray-200 border-b border-gray-300 px-2 py-2 text-xs">
    <div class="flex justify-between">
      <div>
        Hello! <a href="/sign-in" class="underline">Log in</a>
        or <a href="/register" class="underline">Register</a>
        <span class="ml-4">
          | <a href="#">Help</a>
          | <a href="#">Donate</a>
          | <a href="#">Premium Membership</a>
          | <a href="#">Merch</a>
        </span>
      </div>
      <div class="space-x-1">
        <a href="/allbanners" class=""> See all banner ads </a>
        |
        <a href="/banners" class="">Advertise on
        <script>
          document.write(window.location.hostname);
        </script></a>
      </div>
    </div>
    </nav>

    <!-- Logo and Ad Area -->
    <header class="text-white">
    <div class="py-2 bg-[#293F4F]">
      <img src="/images/logo.svg" alt="Logo" class="h-16 px-4" />
    </div>
    <div class="flex bg-[#42637B]">
      <div class="mx-auto ">
        <div class="align-center">
          <div class="relative">
            <.dropdown
              relative="md:relative"
              content_width="large"
              id="test"
              padding="extra_small"
              variant="default"
            >
              <:trigger>
                <.button class="w-full">Dropdown</.button>
              </:trigger>

              <:content>
                <ul class="">
                  <li>Tabs</li>
                  <li>Links</li>
                </ul>
              </:content>
            </.dropdown>
          </div>
        </div>
      </div>
    </div>
    </header>

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

    <!-- Footer -->
    <hr />
    <footer class="text-center text-xs px-8 pt-2 text-gray-600">
    <div class="space-x-2">
      <a href="#">About</a>
      | <a href="#">Help</a>
      | <a href="#">Advertise</a>
      | <a href="#">Donate</a>
      | <a href="#">Privacy/Terms of Use</a>
      | <a href="#">Contact</a>
      | <a href="#">Site Map</a>
    </div>
    <p class="mt-2">Copyright &copy; 1996-2026, Jason Clark. All Rights Reserved.</p>
    <p class="mt-2">
      Not affiliated with or sponsored by Volkswagen of America | Forum powered by phxBB.
    </p>
    <p class="mt-2">
      Links to eBay or other vendor sites may be affiliate links where the site receives compensation.
    </p>
    </footer>
    </div>
    """
  end
end