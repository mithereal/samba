defmodule SambaWeb.NewCategoryLive do
  use SambaWeb, :live_view
  use CKEditor5

  require Logger

  alias CKEditor5.Preset

  def mount(_, _session, socket) do
    form =
      PhpBB.Categories
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
           params: %{
             "cat_title" => "",
             "cat_order" => 0
           }
      )
      |> to_form()

    socket =
      socket
      |> assign(:page_title, "Forums")
      |> assign(:form, form)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
      <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
        <.form for={@form} phx-submit="save" phx-change="validate">
    <.text_field
    id="category-subject"
    name="category-subject"
    value=""
    space="small"
    description="The Category"
    label="Category"
    placeholder=""
    class="mb-4"
    />

    <.textarea_field
    id="category-body"
    name="category-body"
    value=""
    label="Body"
    placeholder="Your message"
    />


          <div class="flex flex-row justify-end space-x-2 mt-4">
            <.button type="submit">Submit</.button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

#  def handle_event("validate", %{"form" => params}, socket) do
#    # Ensure system assigns aren't wiped out if missing from live validation payload
#    merged_params =
#      params
#      |> Map.put("topic_id", socket.assigns.topic_id)
#      |> Map.put("forum_id", socket.assigns.forum_id)
#      |> Map.put("poster_id", socket.assigns.poster_id)
#
#    form = AshPhoenix.Form.validate(socket.assigns.form, merged_params)
#    {:noreply, assign(socket, form: to_form(form))}
#  end

  def handle_event("save", %{"form" => params}, socket) do
    submission_params =
      params
      |> Map.put("topic_id", socket.assigns.topic_id)
      |> Map.put("forum_id", socket.assigns.forum_id)
      |> Map.put("poster_id", socket.assigns.poster_id)
      |> Map.put("post_time", System.os_time(:second))

    case AshPhoenix.Form.submit(socket.assigns.form, params: submission_params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully!")
         |> push_navigate(to: ~p"/forums/topics/#{post.topic_id}")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end
end
