defmodule SambaWeb.NewForumLive do
  use SambaWeb, :live_view
  use CKEditor5

  require Logger

  alias CKEditor5.Preset

  def mount(_, _session, socket) do
    next_order = get_next_order()

    categories =
      PhpBB.Categories
      |> Ash.Query.sort(cat_order: :asc)
      |> Ash.read!(domain: PhpBB.Domain)

    preset =
      Preset.Parser.parse!(%{
        config: %{
          licenseKey: "GPL",
          toolbar: [:bold, :italic, :link],
          plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
        }
      })

    form =
      PhpBB.Forums
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
        params: %{
          "forum_name" => "",
          "forum_desc" => ""
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:page_title, "Forums")
      |> assign(:preset, preset)
      |> assign(:form, form)
      |> assign(:categories, categories)
      |> assign(:forum_order, next_order)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
        <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
          <.form for={@form} phx-submit="save" phx-change="validate">
            <%!-- Hidden inputs for backend state that shouldn't be controlled by visible form inputs --%>>
            <.text_field
              id="post_forum_name"
              field={@form[:forum_name]}
              space="small"
              placeholder="Name"
              variant="default"
              class="mb-4"
              color="white"
            />

            <.text_field
              id="post_forum_desc"
              field={@form[:forum_desc]}
              space="small"
              placeholder="Description"
              variant="default"
              class="mb-4"
              color="white"
            />

            <.input field={@form[:forum_order]} value={@forum_order} type="text" hidden required />

            <div class="flex flex-row justify-end space-x-2 mt-4">
              <.button type="submit">Submit</.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"form" => params}, socket) do
    # Ensure system assigns aren't wiped out if missing from live validation payload
    merged_params =
      params
      |> Map.put("forum_name", socket.assigns.forum_name)
      |> Map.put("forum_desc", socket.assigns.forum_desc)

    form = AshPhoenix.Form.validate(socket.assigns.form, merged_params)
    {:noreply, assign(socket, form: to_form(form))}
  end

  def handle_event("save", %{"form" => params}, socket) do
    submission_params =
      params
      |> Map.put("forum_name", socket.assigns.forum_name)
      |> Map.put("forum_desc", socket.assigns.forum_desc)

    case AshPhoenix.Form.submit(socket.assigns.form, params: submission_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Forum created successfully!")
         |> push_navigate(to: ~p"/forum")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  defp get_next_order do
    max_order =
      PhpBB.Forums
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(forum_order: :desc)
      |> Ash.Query.limit(1)
      |> Ash.read!(domain: Domain)
      |> List.first()
      |> case do
        nil -> 0
        cat -> cat.forum_order || 0
      end

    max_order + 1
  end
end
