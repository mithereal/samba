defmodule SambaWeb.CategoryLive.New do
  use SambaWeb, :live_view

  alias PhpBB.Domain
  alias PhpBB.Categories

  @impl true
  def mount(_params, _session, socket) do
    next_order = get_next_order()

    form =
      Categories
      |> AshPhoenix.Form.for_create(:create,
        domain: Domain,
        as: "form"
      )
      |> to_form()

    {:ok,
     assign(socket,
       form: form,
       cat_order: next_order,
       current_user: socket.assigns[:current_user],
       uri: socket.assigns[:uri]
     )}
  end

  @impl true
  def handle_event("validate", %{"form" => form_params}, socket) do
    form =
      socket.assigns.form
      |> AshPhoenix.Form.validate(form_params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"form" => form_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: form_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully!")
         |> push_navigate(to: ~p"/settings/categories")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <div class="max-w-2xl mx-auto px-4 py-8">
        <div class="mb-6 flex items-center justify-between">
          <h1 class="text-2xl font-bold text-gray-900">New Category</h1>
          <.link
            patch={~p"/settings/categories"}
            class="text-sm font-medium text-indigo-600 hover:text-indigo-900"
          >
            &larr; Back to Categories
          </.link>
        </div>

        <div class="bg-white shadow sm:rounded-lg p-6">
          <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
            <.input field={@form[:cat_title]} type="text" label="Category Title" required />
            <.input field={@form[:cat_order]} value={@cat_order} type="text" hidden required />

            <div class="flex justify-end space-x-3">
              <.link
                patch={~p"/settings/categories"}
                class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
              >
                Cancel
              </.link>
              <button
                type="submit"
                class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Create Category
              </button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp get_next_order do
    max_order =
      Categories
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(cat_order: :desc)
      |> Ash.Query.limit(1)
      |> Ash.read!(domain: Domain)
      |> List.first()
      |> case do
        nil -> 0
        cat -> cat.cat_order || 0
      end

    max_order + 1
  end
end
