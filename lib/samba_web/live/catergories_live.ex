defmodule SambaWeb.CategoryListLive do
  use SambaWeb, :live_view

  alias PhpBB.Categories

  @per_page 10

  @impl true
  def mount(_params, _session, socket) do
    page_num = 1
    offset = (page_num - 1) * @per_page

    page =
      Categories
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(cat_order: :asc)
      |> Ash.Query.page(limit: @per_page, offset: offset, count: true)
      |> Ash.read!()

    categories = page.results
    total_count = page.count || length(categories)
    total_pages = max(ceil(total_count / @per_page), 1)

    socket =
      socket
      |> assign(:page_title, "Categories")
      |> assign(:page, page_num)
      |> assign(:total_pages, total_pages)
      |> assign(:categories, categories)
      |> assign(:reordering, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page_num = String.to_integer(params["page"] || "1")
    offset = (page_num - 1) * @per_page

    page =
      Categories
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(cat_order: :asc)
      |> Ash.Query.page(limit: @per_page, offset: offset, count: true)
      |> Ash.read!()

    categories = page.results
    total_count = page.count || length(categories)
    total_pages = max(ceil(total_count / @per_page), 1)

    {:noreply,
      socket
      |> assign(:page_title, "Categories")
      |> assign(:page, page_num)
      |> assign(:total_pages, total_pages)
      |> assign(:categories, categories)}
  end

  @impl true
  def handle_event("toggle_reorder", _, socket) do
    {:noreply, assign(socket, :reordering, !socket.assigns.reordering)}
  end

  @impl true
  def handle_event("reorder", %{"ids" => ids}, socket) do
    base_offset = (socket.assigns.page - 1) * @per_page

    ids
    |> Enum.with_index(1)
    |> Enum.each(fn {cat_id, index} ->
      new_order = base_offset + index

      Categories
      |> Ash.get!(String.to_integer(cat_id))
      |> Ash.Changeset.for_update(:update, %{cat_order: new_order})
      |> Ash.update!()
    end)

    offset = (socket.assigns.page - 1) * @per_page
    page =
      Categories
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(cat_order: :asc)
      |> Ash.Query.page(limit: @per_page, offset: offset, count: true)
      |> Ash.read!()

    {:noreply, assign(socket, :categories, page.results)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-gray-900">Categories</h1>

        <div class="flex space-x-3">
          <button
            type="button"
            phx-click="toggle_reorder"
            class={"px-4 py-2 rounded-md text-sm font-medium transition-colors border " <> if(@reordering, do: "bg-green-600 text-white border-transparent hover:bg-green-700", else: "bg-white text-gray-700 border-gray-300 hover:bg-gray-50")}>
            {if @reordering, do: "Done Reordering", else: "Change Order"}
          </button>

          <.link
            patch={~p"/categories/new"}
            class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors">
            New Category
          </.link>
        </div>
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <ul
          role="list"
          class="divide-y divide-gray-200"
          id="category-list"
          phx-hook="SortableList">

          <li :for={category <- @categories} id={"category-#{category.cat_id}"} data-id={category.cat_id} class={"px-6 py-4 flex items-center justify-between transition-colors " <> if(@reordering, do: "cursor-grab active:cursor-grabbing bg-gray-50 border-l-4 border-indigo-500", else: "hover:bg-gray-50")}>
            <div class="flex items-center space-x-3 min-w-0 flex-1 pr-4">
              <span :if={@reordering} class="text-indigo-500 font-bold text-lg">&#9776;</span>
              <div>
                <h3 class="text-lg font-medium text-gray-900 truncate">
                  {category.cat_title}
                </h3>
                <p class="mt-1 text-sm text-gray-500">
                  Order: {category.cat_order}
                </p>
              </div>
            </div>

            <div class="flex items-center space-x-3">
              <.link
                patch={~p"/settings/categories/#{category.cat_id}/edit"}
                class="text-indigo-600 hover:text-indigo-900 text-sm font-medium">
                Edit
              </.link>
            </div>
          </li>
        </ul>
      </div>

      <div :if={!@reordering} class="flex items-center justify-between mt-6">
        <div>
          <p class="text-sm text-gray-700">
            Page <span class="font-medium">{@page}</span> of <span class="font-medium">{@total_pages}</span>
          </p>
        </div>

        <div class="flex space-x-2">
          <.link
            :if={@page > 1}
            patch={~p"/settings/categories?page={@page - 1}"}
            class="px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
            Previous
          </.link>

          <.link
            :if={@page < @total_pages}
            patch={~p"/settings/categories?page={@page + 1}"}
            class="px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
            Next
          </.link>
        </div>
      </div>
    </div>
    """
  end
end