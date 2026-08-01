defmodule SambaWeb.NewPostLive do
  use SambaWeb, :live_view
  use CKEditor5

  require Logger

  alias CKEditor5.Preset

  def mount(%{"id" => id}, _session, socket) do
    topic_id = String.to_integer(id)

    # Fetch the topic to get its associated forum_id
    topic = Ash.get!(PhpBB.Topics, topic_id)

    # Set up static/system defaults in mount
    poster_id = 1
    post_time = System.os_time(:second)

    preset =
      Preset.Parser.parse!(%{
        config: %{
          licenseKey: "GPL",
          toolbar: [:bold, :italic, :link],
          plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
        }
      })

    form =
      PhpBB.Posts
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
        params: %{
          "poster_id" => poster_id,
          "topic_id" => topic_id,
          "forum_id" => topic.forum_id,
          "post_time" => post_time,
          "bbcode_uid" => "",
          "enable_bbcode" => 1,
          "enable_smilies" => 1,
          "enable_sig" => 1,
          "enable_html" => 0,
          "post_edit_count" => 0
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:poster_id, poster_id)
      |> assign(:topic_id, topic_id)
      |> assign(:forum_id, topic.forum_id)
      |> assign(:page_title, "Forums")
      |> assign(:preset, preset)
      |> assign(:form, form)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
      <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
        <.form for={@form} phx-submit="save" phx-change="validate">
          <%!-- Hidden inputs for backend state that shouldn't be controlled by visible form inputs --%>
          <input type="hidden" name="form[topic_id]" value={@topic_id} />
          <input type="hidden" name="form[forum_id]" value={@forum_id} />
          <input type="hidden" name="form[poster_id]" value={@poster_id} />

          <.text_field
            id="post_subject"
            field={@form[:post_subject]}
            space="small"
            placeholder="Subject"
            variant="default"
            class="mb-4"
            color="white"
          />
          <div class="mb-4"></div>

          <.ckeditor
            id="content-editor"
            field={@form[:post_text]}
            preset={@preset}
            type="classic"
          />

          <div class="flex flex-row justify-end space-x-2 mt-4">
            <.button type="button">Preview</.button>
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
