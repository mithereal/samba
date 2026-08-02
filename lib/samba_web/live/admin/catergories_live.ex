defmodule SambaWeb.Admin.Category.List.Live do
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
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <div class="flex justify-between mb-6 mx-8">
        <h1 class="text-2xl font-bold text-gray-900">Categories</h1>

        <div class="flex space-x-3">
          <.link
            patch={~p"/settings/categories/new"}
            class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
          >
            New Category
          </.link>
        </div>
      </div>

      <div class="mx-4 px-4 py-8">
        <div class="bg-white shadow overflow-hidden sm:rounded-md">
          <ul
            role="list"
            class="divide-y divide-gray-200"
            id="category-list"
            phx-hook="SortableList"
          >
            <li
              :for={category <- @categories}
              id={"category-#{category.cat_id}"}
              data-id={category.cat_id}
              class="px-6 py-4 flex items-center justify-between transition-colors hover:bg-gray-50"
            >
              <div class="flex items-center space-x-3 min-w-0 flex-1 pr-4">
                <span>&#9776;</span>
                <div>
                  <h3 class="text-lg font-medium text-gray-900 truncate">
                    {category.cat_title}
                  </h3>
                </div>
              </div>

              <div class="flex flex-col space-x-3">
                <div class="text-right">
                  <.link
                    patch={~p"/settings/categories/#{category.cat_id}/edit"}
                    class="text-indigo-600 hover:text-indigo-900 text-sm font-medium"
                  >
                    Edit
                  </.link>
                </div>
                <div class="flex items-center gap-1 mt-1 text-right">
                  <span class="text-xs text-gray-500 ml-1">Order: </span>
                  <span class="text-xs text-gray-500 ml-1">{category.cat_order}</span>
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
              patch={~p"/settings/categories?page={@page - 1}"}
              class="px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Previous
            </.link>

            <.link
              :if={@page < @total_pages}
              patch={~p"/settings/categories?page={@page + 1}"}
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

  defp order_balls(order) when is_integer(order) do
    color_class =
      case rem(order, 5) do
        1 -> "bg-red-500"
        2 -> "bg-blue-500"
        3 -> "bg-green-500"
        4 -> "bg-yellow-500"
        _ -> "bg-purple-500"
      end

    for _i <- 1..max(order, 1) do
      color_class
    end
  end

  defp order_balls(order) when is_binary(order) do
    case Integer.parse(order) do
      {int, _} -> order_balls(int)
      _ -> order_balls(1)
    end
  end
end
