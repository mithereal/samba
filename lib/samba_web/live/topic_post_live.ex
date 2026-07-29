defmodule SambaWeb.TopicPostLive do
  use SambaWeb, :live_view
  use CKEditor5

  require Logger

  alias CKEditor5.Preset

  def mount(%{"id" => id}, _session, socket) do
    topic_id = String.to_integer(id)
    forum_id = String.to_integer(id)

    preset = Preset.Parser.parse!(%{
      config: %{
        licenseKey: "GPL",
        toolbar: [:bold, :italic, :link],
        plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
      }
    })

    form =
      PhpBB.Posts
      |> AshPhoenix.Form.for_create(:create, as: "form",
           params: %{
             "topic_id" => topic_id,
             "forum_id" => forum_id,
             "post_username" => "test",
             "poster_id" => forum_id,
             "poster_ip" => forum_id,
             "post_time" => System.os_time(:second)
           }
         )
      |> to_form()

    socket =
      socket
      |> assign(:page_title, "Forums")
      |> assign(:preset, preset)
      |> assign(:form, form)
IO.inspect form, label: "form"
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
      <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
        <.form for={@form} phx-submit="save" phx-change="validate">
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

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: to_form(form))}
  end

  def handle_event("save", %{"form" => params}, socket) do

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
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