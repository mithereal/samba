defmodule SambaWeb.LandingLive do
  use SambaWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        whats_new: %{date: Calendar.strftime(DateTime.utc_now(), "%b. %d, %Y"), data: []}
      )

    {:ok, socket, temporary_assigns: [{SEO.key(), nil}]}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <!-- Main Content Grid -->
    <main class="flex pt-4 gap-4">
      <!-- Sidebar Left -->
      <aside class="space-y-4">
        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">What's New</span>
                <span class="text-xs text-neutral-500">{@whats_new.date}</span>
              </div>

              {raw(
                Enum.map(@whats_new.data, fn x ->
                  "<p class='break-words text-xs text-neutral-700 pb-2'>#{x}</p>"
                end)
              )}
            </div>
          </.card_content>
        </.card>
        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="bg-orange-200 min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Scam Warnings</span>
              </div>
              <div class="flex items-center flex-col px-2">
                <p>
                  <.link
                    navigate="/page/scams"
                    class="break-words text-sm text-neutral-700 font-semibold"
                  >Internet Scams - General Info</.link>
                </p>
                <p>
                  <.link
                    navigate="/page/fake_emails"
                    class="break-words text-sm text-neutral-700 font-semibold"
                  >Fake emails / Login pages</.link>
                </p>
                <p>
                  <.link
                    navigate="/page/fake_texts"
                    class="break-words text-sm text-neutral-700 font-semibold"
                  >Fake texts</.link>
                </p>
              </div>
            </div>
          </.card_content>
        </.card>

        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 pl-2 pr-1 bg-gray-200 ">
                <span class="font-semibold text-xs">Log-in</span>
                <span class="text-[10px] text-neutral-500"><.link
                  navigate="/reset"
                  class="break-words text-neutral-700 font-semibold"
                >Forgot Username/Password</.link>
                |
                <.link
                  navigate="/register"
                  class="break-words  text-neutral-700 font-semibold"
                >Register</.link></span>
              </div>

              <.form_wrapper for={assigns[:login_form]}>
                <.email_field
                  name="email"
                  value=""
                  size="extra_small"
                  border="none"
                  variant="light"
                  color="natural"
                />
                <.password_field name="password" value="" size="extra_small" color="natural" />
                <div class="flex gap-2 p-2">
                  <.checkbox_field name="remember" color="natural" value="false" class="pl-4" />Keep me logged in
                  <.button>Login</.button>
                </div>
              </.form_wrapper>
            </div>
          </.card_content>
        </.card>

        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Search</span>
              </div>
              <.form_wrapper for={assigns[:search_form]} method="get" action={~p"/search"}>
                <.search_field
                  name="q"
                  value=""
                  placeholder=""
                  search_button
                  class="text-xs p-2"
                  size="small"
                />
              </.form_wrapper>
            </div>
          </.card_content>
        </.card>

        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Classifieds</span>
              </div>
              <.image
                src="/images/logo.svg"
                alt="image"
                srcset="/images/logo.svg 300w,
    /images/logo.svg 600w"
                sizes="(max-width: 600px) 100vw, 50vw"
                loading="lazy"
                ismap
                decoding="async"
                fetchpriority="high"
                referrerpolicy="no-referrer"
                width="300"
                height="200"
              />
            </div>
          </.card_content>
        </.card>
        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Gallery</span>
              </div>
              <.carousel
                id="gallery_slides"
                size="extra_small"
                control="false"
                autoplay="true"
                padding="padding"
                class="flex justify-center items-center w-full"
              >
                <:slide image="/images/logo.svg" class="w-[100px] h-[100px] object-cover" />
                <:slide image="/images/logo.svg" class="w-[100px] h-[100px] object-cover" />
              </.carousel>
            </div>
          </.card_content>
        </.card>
      </aside>

      <!-- Main Content Middle -->
      <section class="mx-auto min-h-[70vh] grow">
        <.jumbotron class="flex px-10 py-10">
          <div>
            <.image
              src={assigns[:vw_fact][:image]}
              alt="image"
              srcset="{assigns[:vw_fact][:image]} 300w,
    {assigns[:vw_fact][:image]} 600w"
              sizes="(max-width: 600px) 100vw, 50vw"
              loading="lazy"
              ismap
              decoding="async"
              fetchpriority="high"
              referrerpolicy="no-referrer"
              width="300"
              height="200"
            />
          </div>
          <div>
            {assigns[:vw_fact][:data]}
          </div>
        </.jumbotron>
        <div>
          <div class="flex justify-between items-center mt-2 mb-2 bg-gray-200 px-2">
            <span class="font-semibold text-xs">Featured Ads</span>
            <span class="text-xs text-neutral-500"><.link
              navigate="/classifieds/featured"
              class="break-words text-sm text-neutral-700 font-semibold"
            >I want a featured ad</.link></span>
          </div>

          <.gallery
            type="masonry"
            cols="four"
            animation="backdrop"
            animation_size="extra_small"
            gap="medium"
            class="px-4"
          >
            <div>
              <.gallery_media src="/images/logo.svg" /> fuc it
            </div>
          </.gallery>
        </div>
      </section>

      <!-- Sidebar Right -->
      <aside class="space-y-4">
        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Advertisement</span>
              </div>
              <.image
                src="/images/logo.svg"
                alt="image"
                srcset="/images/logo.svg 300w,
    /images/logo.svg 600w"
                sizes="(max-width: 600px) 100vw, 50vw"
                loading="lazy"
                ismap
                decoding="async"
                fetchpriority="high"
                referrerpolicy="no-referrer"
                width="100"
                height="100"
              />
            </div>
          </.card_content>
        </.card>
        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Stolen</span>
              </div>
              <.image
                src="/images/logo.svg"
                alt="image"
                srcset="/images/logo.svg 300w,
    /images/logo.svg 600w"
                sizes="(max-width: 600px) 100vw, 50vw"
                loading="lazy"
                ismap
                decoding="async"
                fetchpriority="high"
                referrerpolicy="no-referrer"
                width="100"
                height="100"
              />
            </div>
          </.card_content>
        </.card>
        <.card>
          <.card_content class="flex justify-around h-full">
            <div class="min-w-xs max-w-xs border rounded shadow">
              <div class="flex justify-between items-center mb-2 bg-gray-200 px-2">
                <span class="font-semibold text-xs">Upcoming Events</span>
              </div>
              <.scroll_area
                id="baseui-scroll_area-scroll-fade"
                orientation="vertical"
                class="h-36 w-96 max-w-[calc(100vw-8rem)] bg-neutral-100 dark:bg-neutral-800 has-[>_[data-part=viewport]:focus-visible]:outline-2 has-[>_[data-part=viewport]:focus-visible]:outline-offset-0 has-[>_[data-part=viewport]:focus-visible]:outline-neutral-950 dark:has-[>_[data-part=viewport]:focus-visible]:outline-white"
                viewport_class="h-full bg-neutral-100 dark:bg-neutral-800 outline-none mask-linear-[to_bottom,transparent_0,black_min(40px,var(--scroll-area-overflow-y-start)),black_calc(100%_-_min(40px,var(--scroll-area-overflow-y-end,40px))),transparent_100%] mask-no-repeat"
                content_class="flex flex-col gap-4 py-2 pr-5 pl-3 text-sm leading-[1.375rem] text-neutral-950 dark:text-white"
                scrollbar_class="m-px flex w-4 justify-center bg-black/8 dark:bg-white/12 opacity-0 transition-opacity duration-150 pointer-events-none data-[hovering]:opacity-100 data-[hovering]:pointer-events-auto data-[scrolling]:opacity-100 data-[scrolling]:duration-0 data-[scrolling]:pointer-events-auto"
                thumb_class="w-full h-[var(--scroll-area-thumb-height)] bg-neutral-950 dark:bg-white"
              >
                <p>
                  Vernacular architecture is building done outside any academic tradition, and without
                  professional guidance. It is not a particular architectural movement or style, but
                  rather a broad category, encompassing a wide range and variety of building types, with
                  differing methods of construction, from around the world, both historical and extant and
                  classical and modern. Vernacular architecture constitutes 95% of the world's built
                  environment, as estimated in 1995 by Amos Rapoport, as measured against the small
                  percentage of new buildings every year designed by architects and built by engineers.
                </p>
                <p>
                  This type of architecture usually serves immediate, local needs, is constrained by the
                  materials available in its particular region and reflects local traditions and cultural
                  practices. The study of vernacular architecture does not examine formally schooled
                  architects, but instead that of the design skills and tradition of local builders, who
                  were rarely given any attribution for the work. More recently, vernacular architecture
                  has been examined by designers and the building industry in an effort to be more energy
                  conscious with contemporary design and construction—part of a broader interest in
                  sustainable design.
                </p>
              </.scroll_area>
            </div>
          </.card_content>
        </.card>
      </aside>
    </main>
    """
  end

  #  def handle_params(params, _uri, socket) do
  #    {:noreply, SEO.assign(socket, load_article(params))}
  #  end
end
