defmodule SambaWeb.Admin.Forums.List.Live do
  use SambaWeb, :live_view

  alias PhpBB.Forums
  alias PhpBB.Categories

  @per_page 10

  @impl true
  def mount(params, _session, socket) do
    categories =
      Categories |> Ash.Query.for_read(:read) |> Ash.Query.sort(cat_order: :asc) |> Ash.read!()

    selected_cat_id =
      params["cat_id"] || (List.first(categories) && to_string(List.first(categories).cat_id))

    page_num = 1
    offset = (page_num - 1) * @per_page

    page = fetch_forums_page(selected_cat_id, offset, @per_page)
    forums = page.results
    total_count = page.count || length(forums)
    total_pages = max(ceil(total_count / @per_page), 1)

    socket =
      socket
      |> assign(:page_title, "Forums")
      |> assign(:categories, categories)
      |> assign(:selected_cat_id, selected_cat_id)
      |> assign(:page, page_num)
      |> assign(:total_pages, total_pages)
      |> assign(:forums, forums)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    categories = socket.assigns.categories

    selected_cat_id =
      params["cat_id"] ||
        socket.assigns[:selected_cat_id] ||
        (List.first(categories) && to_string(List.first(categories).cat_id))

    page_num = String.to_integer(params["page"] || "1")
    offset = (page_num - 1) * @per_page

    page = fetch_forums_page(selected_cat_id, offset, @per_page)

    forums = page.results
    total_count = page.count || length(forums)
    total_pages = max(ceil(total_count / @per_page), 1)

    {:noreply,
     socket
     |> assign(:page_title, "Forums")
     |> assign(:selected_cat_id, selected_cat_id)
     |> assign(:page, page_num)
     |> assign(:total_pages, total_pages)
     |> assign(:forums, forums)}
  end

  @impl true
  def handle_event("change_category", %{"value" => cat_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/settings/forums?cat_id=#{cat_id}&page=1")}
  end

  @impl true
  def handle_event("change_category", %{"category_id" => cat_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/settings/forums?cat_id=#{cat_id}&page=1")}
  end

  @impl true
  def handle_event("reorder", %{"ids" => ids}, socket) do
    base_offset = (socket.assigns.page - 1) * @per_page

    ids
    |> Enum.with_index(1)
    |> Enum.each(fn {forum_id, index} ->
      new_order = base_offset + index

      Forums
      |> Ash.get!(String.to_integer(forum_id))
      |> Ash.Changeset.for_update(:update, %{forum_order: new_order})
      |> Ash.update!()
    end)

    offset = (socket.assigns.page - 1) * @per_page
    page = fetch_forums_page(socket.assigns.selected_cat_id, offset, @per_page)

    {:noreply, assign(socket, :forums, page.results)}
  end

  @impl true
  def render(assigns) do
    category_options =
      Enum.map(assigns.categories, &%{value: to_string(&1.cat_id), label: &1.cat_title})

    current_category =
      Enum.find(assigns.categories, &(to_string(&1.cat_id) == assigns.selected_cat_id))

    assigns = assign(assigns, :category_options, category_options)
    assigns = assign(assigns, :current_category, current_category)

    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <div class="flex justify-between items-center mb-6 mx-8">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">
            {if @current_category, do: @current_category.cat_title, else: "Forums"}
          </h1>
          <p class="text-sm text-gray-500 mt-1">Manage forums organized by category</p>
        </div>

        <div class="flex items-center space-x-3">
          <div class="w-64">
            <.select
              id="category-filter-select"
              name="category_id"
              placeholder="Select Category"
              class="flex flex-col items-start gap-1"
              label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
              trigger_class="flex h-8 min-w-40 items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
              value_class="data-[placeholder]:text-neutral-500 dark:data-[placeholder]:text-neutral-400"
              icon_class="flex items-center"
              positioner_class="outline-hidden select-none z-10"
              popup_class="group min-w-[var(--anchor-width)] origin-[var(--transform-origin)] py-1 bg-clip-padding border border-neutral-950 bg-white text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[side=none]:translate-y-px data-[side=none]:min-w-[calc(var(--anchor-width)+1.75rem)] data-[side=none]:data-[ending-style]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[side=none]:data-[starting-style]:scale-100 data-[side=none]:data-[starting-style]:opacity-100 data-[side=none]:data-[starting-style]:transition-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
              item_class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-1.5 pr-4 pl-2.5 text-sm outline-hidden select-none data-[highlighted]:bg-neutral-950 data-[highlighted]:text-white dark:data-[highlighted]:bg-white dark:data-[highlighted]:text-neutral-950"
              item_indicator_class="col-start-1"
              item_text_class="col-start-2"
              options={@category_options}
              value={@selected_cat_id}
              on_change="change_category"
            />
          </div>

          <.link
            navigate={~p"/settings/forums/new"}
            class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
          >
            New Forum
          </.link>
        </div>
      </div>

      <div class="mx-4 px-4 py-8">
        <div class="bg-white shadow overflow-hidden sm:rounded-md">
          <ul
            role="list"
            class="divide-y divide-gray-200"
            id="forum-list"
            phx-hook="SortableList"
          >
            <li
              :for={forum <- @forums}
              id={"forum-#{forum.forum_id}"}
              data-id={forum.forum_id}
              class="px-6 py-4 flex items-center justify-between transition-colors hover:bg-gray-50"
            >
              <div class="flex items-center space-x-3 min-w-0 flex-1 pr-4">
                <span>&#9776;</span>
                <div>
                  <h3 class="text-lg font-medium text-gray-900 truncate">
                    {forum.forum_name}
                  </h3>
                </div>
              </div>

              <div class="flex flex-col space-x-3">
                <div class="text-right">
                  <.link
                    navigate={~p"/settings/forums/#{forum.forum_id}/edit"}
                    class="text-indigo-600 hover:text-indigo-900 text-sm font-medium"
                  >
                    Edit
                  </.link>
                </div>
                <div class="flex items-center gap-1 mt-1 text-right">
                  <span class="text-xs text-gray-500 ml-1">Order: </span>
                  <span class="text-xs text-gray-500 ml-1">{forum.forum_order}</span>
                </div>
              </div>
            </li>
          </ul>
        </div>

        <div class="flex items-center justify-between mt-6">
          <div>
            <p class="text-sm text-gray-700">
              Page <span class="font-medium">{@page}</span>
              of <span class="font-medium">{@total_pages}</span>
            </p>
          </div>

          <div class="flex space-x-2">
            <.link
              :if={@page > 1}
              navigate={~p"/settings/forums?cat_id={@selected_cat_id}&page={@page - 1}"}
              class="px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Previous
            </.link>

            <.link
              :if={@page < @total_pages}
              navigate={~p"/settings/forums?cat_id={@selected_cat_id}&page={@page + 1}"}
              class="px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Next
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp fetch_forums_page(nil, _offset, _limit), do: %{results: [], count: 0}

  defp fetch_forums_page(cat_id, offset, limit) when is_binary(cat_id) do
    case Integer.parse(cat_id) do
      {numeric_id, _} ->
        fetch_forums_page(numeric_id, offset, limit)

      :error ->
        %{results: [], count: 0}
    end
  end

  defp fetch_forums_page(cat_id, offset, limit) do
    query =
      Forums
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter_input(cat_id: cat_id)
      |> Ash.Query.sort(forum_order: :asc)
      |> Ash.Query.page(limit: limit, offset: offset, count: true)

    Ash.read!(query)
  end
end
