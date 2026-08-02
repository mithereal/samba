defmodule SambaWeb.NewTopicLive do
  use SambaWeb, :live_view
  use CKEditor5
  use SambaWeb.LiveTracking

  require Logger

  alias CKEditor5.Preset
  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  def mount(%{"id" => id}, _session, socket) do
    form_id = String.to_integer(id)
    forum = Ash.get!(PhpBB.Forums, form_id)
    current_user = socket.assigns[:current_user]

    preset =
      Preset.Parser.parse!(%{
        config: %{
          licenseKey: "GPL",
          toolbar: [:bold, :italic, :link],
          plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
        }
      })

    form =
      PhpBB.Topics
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
        params: %{
          "forum_id" => forum.forum_id,
          "topic_poster" => current_user.phpbb_user_id
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:poster_id, current_user.phpbb_user_id)
      |> assign(:forum_id, forum.forum_id)
      |> assign(:page_title, "New Topic")
      |> assign(:preset, preset)
      |> assign(:form, form)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <Layouts.flash_group flash={@flash} />
    <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
      <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
        <.form for={@form} phx-submit="safe_save">
          <input type="hidden" name="form[forum_id]" value={@forum_id} />
          <input type="hidden" name="form[topic_poster]" value={@poster_id} />

          <.text_field
            id="topic_title"
            field={@form[:topic_title]}
            space="small"
            placeholder="Subject"
            variant="default"
            class="mb-4"
            color="white"
          />
          <div class="mb-4"></div>

          <div class="mb-4">
            <div class="flex justify-between items-center mb-1">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white">Post Text</label>
              <div class="text-xs space-x-2 text-indigo-600 dark:text-indigo-400 font-medium">
                <.link navigate={~p"/help/photos"} class="hover:underline">How to post photos</.link>
                <span>|</span>
                <.link navigate={~p"/gallery/upload"} class="hover:underline">Upload a photo to the Gallery</.link>
                <span>|</span>
                <.link navigate={~p"/gallery/my-photos"} class="hover:underline">Show all my Gallery photos</.link>
              </div>
            </div>
            <div class="[&_.ck-editor__editable]:!min-h-[20rem]">
              <.ckeditor
                id="content-editor"
                field={@form[:post_text]}
                preset={@preset}
                type="classic"
              />
            </div>
          </div>

          <!-- Post Options Checkboxes -->
          <div class="space-y-2 mb-6 p-4 rounded-md border border-gray-300 dark:border-gray-700 bg-white/50 dark:bg-neutral-900/50">
            <h3 class="text-sm font-bold text-neutral-950 dark:text-white mb-3">Options</h3>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <label class="flex items-center space-x-2 cursor-pointer">
                <input type="hidden" name="form[disable_html]" value="false" />
                <input
                  type="checkbox"
                  name="form[disable_html]"
                  value="true"
                  checked={@form[:disable_html].value in [true, "true", 1]}
                  class="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                />
                <span class="text-sm font-medium text-neutral-950 dark:text-white">Disable HTML in this post</span>
              </label>

              <label class="flex items-center space-x-2 cursor-pointer">
                <input type="hidden" name="form[disable_bbcode]" value="false" />
                <input
                  type="checkbox"
                  name="form[disable_bbcode]"
                  value="true"
                  checked={@form[:disable_bbcode].value in [true, "true", 1]}
                  class="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                />
                <span class="text-sm font-medium text-neutral-950 dark:text-white">Disable BBCode in this post</span>
              </label>

              <label class="flex items-center space-x-2 cursor-pointer">
                <input type="hidden" name="form[disable_smilies]" value="false" />
                <input
                  type="checkbox"
                  name="form[disable_smilies]"
                  value="true"
                  checked={@form[:disable_smilies].value in [true, "true", 1]}
                  class="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                />
                <span class="text-sm font-medium text-neutral-950 dark:text-white">Disable Smilies in this post</span>
              </label>

              <label class="flex items-center space-x-2 cursor-pointer">
                <input type="hidden" name="form[notify_reply]" value="false" />
                <input
                  type="checkbox"
                  name="form[notify_reply]"
                  value="true"
                  checked={@form[:notify_reply].value in [true, "true", 1]}
                  class="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                />
                <span class="text-sm font-medium text-neutral-950 dark:text-white">Notify me when a reply is posted</span>
              </label>
            </div>
          </div>

          <div class="flex flex-row justify-end space-x-2 mt-4">
            <.link
              navigate={~p"/forums/#{@forum_id}"}
              class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
            >
              Cancel
            </.link>
            <.button
              type="submit"
              class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium"
            >
              Submit Topic
            </.button>
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

  def handle_event("safe_save", %{"form" => params}, socket) do
    poster_id = socket.assigns.poster_id
    forum_id = socket.assigns.forum_id
    post_time = System.os_time(:second)
    forum_record = Ash.get!(PhpBB.Forums, forum_id, domain: PhpBB.Domain)

    topic_title = String.trim(params["topic_title"])
    post_text_content = String.trim(params["post_text"])

    if String.length(topic_title) < 3 || String.length(post_text_content) < 3 do
      form = AshPhoenix.Form.validate(socket.assigns.form, params)

      {:noreply,
       socket
       |> put_flash(:error, "Subject and Post Text cannot be blank.")
       |> assign(form: to_form(form))}
    else
      {:ok, topic} =
        PhpBB.Topics
        |> Ash.Changeset.for_create(:create, %{
          "forum_id" => forum_id,
          "topic_poster" => poster_id,
          "topic_title" => topic_title,
          "topic_time" => post_time,
          "topic_replies" => 0,
          "topic_views" => 0,
          "topic_status" => 0,
          "topic_vote" => 0,
          "topic_type" => 0,
          "first_post_id" => nil,
          "last_post_id" => nil,
          "topic_moved_id" => nil
        })
        |> Ash.create(domain: PhpBB.Domain)

      {:ok, post} =
        PhpBB.Posts
        |> Ash.Changeset.for_create(:create, %{
          "topic_id" => topic.topic_id,
          "forum_id" => forum_id,
          "poster_id" => poster_id,
          "post_time" => post_time,
          "post_username" => "",
          "poster_ip" => "00000000",
          "enable_bbcode" => 1,
          "enable_html" => 1,
          "enable_smilies" => 1,
          "enable_sig" => 1,
          "post_edit_time" => 0,
          "post_edit_count" => 0
        })
        |> Ash.create(domain: PhpBB.Domain)

      {:ok, post_text} =
        PhpBB.PostsText
        |> Ash.Changeset.for_create(:create, %{
          "post_id" => post.post_id,
          "bbcode_uid" => "0",
          "post_subject" => topic_title,
          "post_text" => post_text_content
        })
        |> Ash.create(domain: PhpBB.Domain)

      {:ok, updated_topic} =
        topic
        |> Ash.Changeset.for_update(:update, %{
          "first_post_id" => post.post_id,
          "last_post_id" => post.post_id,
          "topic_replies" => 0
        })
        |> Ash.update(domain: PhpBB.Domain)

      {:ok, updated_forum} =
        forum_record
        |> Ash.Changeset.for_update(:update, %{
          "forum_last_post_id" => post.post_id
        })
        |> Ash.update(domain: PhpBB.Domain)

      {:noreply,
       socket
       |> put_flash(:info, "Topic and post created successfully!")}
    end
  end

  def handle_event("save", %{"form" => params}, socket) do
    poster_id = socket.assigns.poster_id
    forum_id = socket.assigns.forum_id
    post_time = System.os_time(:second)

    forum_record = Ash.get!(PhpBB.Forums, forum_id, domain: PhpBB.Domain)

    topic_title = String.trim(params["topic_title"] || "")
    ## this is emptyvalidation is failing
    post_text_content = String.trim(params["post_text"] || "")

    if String.length(topic_title) < 1 || String.length(post_text_content) < 1 do
      form = AshPhoenix.Form.validate(socket.assigns.form, params)

      {:noreply,
       socket
       |> put_flash(:error, "Subject and Post Text cannot be blank.")
       |> assign(form: to_form(form))}
    else
      enable_html = if params["disable_html"] == "true", do: 0, else: 1
      enable_bbcode = if params["disable_bbcode"] == "true", do: 0, else: 1
      enable_smilies = if params["disable_smilies"] == "true", do: 0, else: 1

      with {:ok, topic} <-
             PhpBB.Topics
             |> Ash.Changeset.for_create(:create, %{
               "forum_id" => forum_id,
               "topic_poster" => poster_id,
               "topic_title" => topic_title,
               "topic_time" => post_time,
               "topic_replies" => 0,
               "topic_views" => 0,
               "topic_status" => 0,
               "topic_vote" => 0,
               "topic_type" => 0,
               "first_post_id" => nil,
               "last_post_id" => nil,
               "topic_moved_id" => nil
             })
             |> Ash.create(domain: PhpBB.Domain),
           {:ok, post} <-
             PhpBB.Posts
             |> Ash.Changeset.for_create(:create, %{
               "topic_id" => topic.topic_id,
               "forum_id" => forum_id,
               "poster_id" => poster_id,
               "post_time" => post_time,
               "post_username" => "",
               "poster_ip" => "00000000",
               "enable_bbcode" => 1,
               "enable_html" => 1,
               "enable_smilies" => 1,
               "enable_sig" => 1,
               "post_edit_time" => 0,
               "post_edit_count" => 0
             })
             |> Ash.create(domain: PhpBB.Domain),
           {:ok, post_text} <-
             PhpBB.PostsText
             |> Ash.Changeset.for_create(:create, %{
               "post_id" => post.post_id,
               "bbcode_uid" => "0",
               "post_subject" => topic_title,
               "post_text" => post_text_content
             })
             |> Ash.create(domain: PhpBB.Domain),
           {:ok, updated_topic} <-
             topic
             |> Ash.Changeset.for_update(:update, %{
               "topic_replies" => post.post_id
             })
             |> Ash.update(domain: PhpBB.Domain),
           {:ok, updated_forum} <-
             forum_record
             |> Ash.Changeset.for_update(:update, %{
               "forum_posts" => post.post_id,
               "forum_topics" => post.post_id,
               "forum_last_post_id" => 0
             })
             |> Ash.update(domain: PhpBB.Domain) do
        {:noreply,
         socket
         |> put_flash(:info, "Topic and post created successfully!")
         |> push_navigate(to: ~p"/topics/#{updated_topic.topic_id}")}
      else
        {:error, error} ->
          Logger.error("FAILED SEQUENTIAL STEP: #{inspect(error, pretty: true)}")

          form =
            socket.assigns.form
            |> AshPhoenix.Form.validate(params)

          {:noreply,
           socket
           |> put_flash(:error, "Failed to create topic. Check server logs.")
           |> assign(form: to_form(form))}

        error ->
          Logger.error("UNMATCHED SEQUENTIAL ERROR: #{inspect(error, pretty: true)}")

          form =
            socket.assigns.form
            |> AshPhoenix.Form.validate(params)

          {:noreply,
           socket
           |> put_flash(:error, "Failed to create topic. Check server logs.")
           |> assign(form: to_form(form))}
      end
    end
  end
end
