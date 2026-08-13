defmodule SambaWeb.NewTopicLive do
  use SambaWeb, :live_view
  use CKEditor5
  use SambaWeb.LiveTracking

  require Logger
  import Ash.Query

  alias CKEditor5.Preset
  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  def mount(%{"id" => id}, _session, socket) do
    forum_id = String.to_integer(id)
    forum = Ash.get!(PhpBB.Forums, forum_id, domain: PhpBB.Domain)
    current_user = socket.assigns[:current_user]
    poster_id = current_user.phpbb_user_id

    {can_post_sticky, can_post_announce} = evaluate_topic_permissions(forum, current_user)

    preset =
      Preset.Parser.parse!(%{
        config: %{
          toolbar: [:bold, :italic, :link],
          plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
        }
      })

    form =
      PhpBB.Topics
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
        domain: PhpBB.Domain,
        params: %{
          "forum_id" => forum.forum_id,
          "topic_poster" => poster_id,
          "disable_html" => "false",
          "disable_bbcode" => "false",
          "disable_smilies" => "false",
          "notify_reply" => "false",
          "topic_type" => "0",
          "post_text" => ""
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:forum, forum)
      |> assign(:poster_id, poster_id)
      |> assign(:forum_id, forum.forum_id)
      |> assign(:can_post_sticky, can_post_sticky)
      |> assign(:can_post_announce, can_post_announce)
      |> assign(:page_title, "New Topic")
      |> assign(:preset, preset)
      |> assign(:form, form)

    {:ok, socket}
  end

  def mount(%{"forum_id" => id}, _session, socket) do
    forum_id = String.to_integer(id)
    forum = Ash.get!(PhpBB.Forums, forum_id, domain: PhpBB.Domain)
    current_user = socket.assigns[:current_user]
    poster_id = current_user.phpbb_user_id

    {can_post_sticky, can_post_announce} = evaluate_topic_permissions(forum, current_user)
    {can_post_sticky, can_post_announce} = evaluate_topic_permissions(forum, current_user)

    preset =
      Preset.Parser.parse!(%{
        config: %{
          toolbar: [:bold, :italic, :link],
          plugins: [:Bold, :Italic, :Link, :Essentials, :Paragraph]
        }
      })

    form =
      PhpBB.Topics
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
        domain: PhpBB.Domain,
        params: %{
          "forum_id" => forum.forum_id,
          "topic_poster" => poster_id,
          "disable_html" => "false",
          "disable_bbcode" => "false",
          "disable_smilies" => "false",
          "notify_reply" => "false",
          "topic_type" => "0",
          "post_text" => ""
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:forum, forum)
      |> assign(:poster_id, poster_id)
      |> assign(:forum_id, forum.forum_id)
      |> assign(:can_post_sticky, can_post_sticky)
      |> assign(:can_post_announce, can_post_announce)
      |> assign(:page_title, "New Topic")
      |> assign(:preset, preset)
      |> assign(:form, form)

    {:ok, socket}
  end

  defp evaluate_topic_permissions(forum, user) do
    user_level = Map.get(user, :user_level, 0) || 0

    if user_level in [1, 2] do
      {true, true}
    else
      sticky_auth = forum.auth_sticky || 0
      announce_auth = forum.auth_announce || 0

      {
        check_auth_level(forum, sticky_auth, user, :auth_sticky),
        check_auth_level(forum, announce_auth, user, :auth_announce)
      }
    end
  end

  defp check_auth_level(forum, auth_val, user, permission_field) do
    user_level = Map.get(user, :user_level, 0) || 0

    cond do
      auth_val == 0 -> true
      auth_val == 1 -> user_level >= 0
      auth_val == 3 -> user_level in [1, 2]
      auth_val == 5 -> user_level == 1
      auth_val == 2 -> check_acl_permission(forum, user, permission_field)
      true -> false
    end
  end

  defp check_acl_permission(forum, user, permission_field) do
    user_id = Map.get(user, :phpbb_user_id)

    if is_nil(user_id) do
      false
    else
      try do
        group_ids =
          PhpBB.UserGroup
          |> Ash.Query.filter(user_id == ^user_id and user_pending == 0)
          |> Ash.read!(domain: PhpBB.Domain)
          |> Enum.map(& &1.group_id)

        if Enum.empty?(group_ids) do
          false
        else
          auth_records =
            PhpBB.AuthAccess
            |> Ash.Query.filter(forum_id == ^forum.forum_id and group_id in ^group_ids)
            |> Ash.read!(domain: PhpBB.Domain)

          Enum.any?(auth_records, fn record ->
            Map.get(record, permission_field) == 1
          end)
        end
      rescue
        e ->
          Logger.error("Failed to evaluate ACL permissions: #{inspect(e)}")
          false
      end
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.top current_user={assigns[:current_user] || nil} />
    <Layouts.flash_group flash={@flash} />
    <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
      <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
        <.form for={@form} phx-submit="save_topic">
          <input type="hidden" name="form[forum_id]" value={@forum_id} />
          <input type="hidden" name="form[topic_poster]" value={@poster_id} />
          <%= if @can_post_sticky || @can_post_announce do %>
            <div class="mb-4">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white mb-1">Topic Type</label>
              <div class="flex items-center space-x-6 text-sm text-neutral-950 dark:text-white">
                <label class="flex items-center space-x-2 cursor-pointer">
                  <input
                    type="radio"
                    name="form[topic_type]"
                    value="0"
                    checked={Phoenix.HTML.Form.input_value(@form, :topic_type) in [0, "0", nil]}
                    class="text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                  />
                  <span>Normal</span>
                </label>

                <%= if @can_post_sticky do %>
                  <label class="flex items-center space-x-2 cursor-pointer">
                    <input
                      type="radio"
                      name="form[topic_type]"
                      value="1"
                      checked={Phoenix.HTML.Form.input_value(@form, :topic_type) in [1, "1"]}
                      class="text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                    />
                    <span>Sticky</span>
                  </label>
                <% end %>

                <%= if @can_post_announce do %>
                  <label class="flex items-center space-x-2 cursor-pointer">
                    <input
                      type="radio"
                      name="form[topic_type]"
                      value="2"
                      checked={Phoenix.HTML.Form.input_value(@form, :topic_type) in [2, "2"]}
                      class="text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                    />
                    <span>Announcement</span>
                  </label>
                <% end %>
              </div>
            </div>
          <% end %>

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
              />
            </div>
          </div>

          <div class="space-y-2 mb-6 p-4 rounded-md border border-gray-300 dark:border-gray-700 bg-white/50 dark:bg-neutral-900/50">
            <h3 class="text-sm font-bold text-neutral-950 dark:text-white mb-3">Options</h3>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <label class="flex items-center space-x-2 cursor-pointer">
                <input type="hidden" name="form[disable_html]" value="false" />
                <input
                  type="checkbox"
                  name="form[disable_html]"
                  value="true"
                  checked={
                    Phoenix.HTML.Form.input_value(@form, :disable_html) in [true, "true", 1, "1"]
                  }
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
                  checked={
                    Phoenix.HTML.Form.input_value(@form, :disable_bbcode) in [true, "true", 1, "1"]
                  }
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
                  checked={
                    Phoenix.HTML.Form.input_value(@form, :disable_smilies) in [true, "true", 1, "1"]
                  }
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
                  checked={
                    Phoenix.HTML.Form.input_value(@form, :notify_reply) in [true, "true", 1, "1"]
                  }
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
    form_params =
      Map.drop(params, [
        "post_text",
        "disable_html",
        "disable_bbcode",
        "disable_smilies",
        "notify_reply"
      ])

    form = AshPhoenix.Form.validate(socket.assigns.form, form_params)
    {:noreply, assign(socket, form: to_form(form))}
  end

  def handle_event("save_topic", %{"form" => params}, socket) do
    poster_id = socket.assigns.poster_id
    forum_id = socket.assigns.forum_id
    can_post_sticky = socket.assigns.can_post_sticky
    can_post_announce = socket.assigns.can_post_announce
    post_time = System.os_time(:second)

    forum_record = socket.assigns.forum

    topic_title = String.trim(params["topic_title"] || "")
    post_text_content = String.trim(params["post_text"] || "")

    if String.length(topic_title) < 1 || String.length(post_text_content) < 1 do
      form_params =
        Map.drop(params, [
          "post_text",
          "disable_html",
          "disable_bbcode",
          "disable_smilies",
          "notify_reply"
        ])

      form = AshPhoenix.Form.validate(socket.assigns.form, form_params)

      {:noreply,
       socket
       |> put_flash(:error, "Subject and Post Text cannot be blank.")
       |> assign(form: to_form(form))}
    else
      enable_html = if params["disable_html"] in ["true", "1", true], do: 0, else: 1
      enable_bbcode = if params["disable_bbcode"] in ["true", "1", true], do: 0, else: 1
      enable_smilies = if params["disable_smilies"] in ["true", "1", true], do: 0, else: 1

      parsed_type =
        case Integer.parse(params["topic_type"] || "0") do
          {int, _} -> int
          :error -> 0
        end

      topic_type =
        cond do
          parsed_type == 1 && can_post_sticky -> 1
          parsed_type == 2 && can_post_announce -> 2
          true -> 0
        end

      case create_topic_record(
             forum_id,
             poster_id,
             topic_title,
             post_time,
             topic_type,
             forum_record,
             enable_html,
             enable_bbcode,
             enable_smilies,
             post_text_content
           ) do
        {:ok, updated_topic} ->
          {:noreply,
           socket
           |> put_flash(:info, "Topic and post created successfully!")
           |> push_navigate(to: ~p"/topic/#{updated_topic.topic_id}")}

        {:error, error} ->
          Logger.error("FAILED TOPIC CREATION: #{inspect(error, pretty: true)}")

          form_params =
            Map.drop(params, [
              "post_text",
              "disable_html",
              "disable_bbcode",
              "disable_smilies",
              "notify_reply"
            ])

          form =
            socket.assigns.form
            |> AshPhoenix.Form.validate(form_params)

          {:noreply,
           socket
           |> put_flash(:error, "Failed to create topic. Check server logs.")
           |> assign(form: to_form(form))}
      end
    end
  end

  defp create_topic_record(
         forum_id,
         poster_id,
         topic_title,
         post_time,
         topic_type,
         forum_record,
         enable_html \\ 1,
         enable_bbcode \\ 1,
         enable_smilies \\ 1,
         post_text_content \\ ""
       ) do
    with {:ok, topic} <-
           create_base_topic(forum_id, poster_id, topic_title, post_time, topic_type),
         {:ok, post} <-
           create_post_record(
             topic.topic_id,
             forum_id,
             poster_id,
             post_time,
             enable_html,
             enable_bbcode,
             enable_smilies
           ),
         {:ok, _post_text} <-
           create_post_text_record(post.post_id, topic_title, post_text_content),
         {:ok, updated_topic} <- update_topic_pointers(topic, post.post_id),
         {:ok, _updated_forum} <- update_forum_last_post(forum_record, post.post_id) do
      {:ok, updated_topic}
    end
  end

  def create_base_topic(forum_id, poster_id, topic_title, post_time, topic_type) do
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
      "topic_type" => topic_type,
      "topic_moved_id" => nil
    })
    |> Ash.create(domain: PhpBB.Domain)
  end

  def create_post_record(
        topic_id,
        forum_id,
        poster_id,
        post_time,
        enable_html,
        enable_bbcode,
        enable_smilies
      ) do
    PhpBB.Posts
    |> Ash.Changeset.for_create(:create, %{
      "topic_id" => topic_id,
      "forum_id" => forum_id,
      "poster_id" => poster_id,
      "post_time" => post_time,
      "post_username" => "",
      "poster_ip" => "127.0.0.1",
      "enable_bbcode" => enable_bbcode,
      "enable_html" => enable_html,
      "enable_smilies" => enable_smilies,
      "enable_sig" => 1,
      "post_edit_time" => 0,
      "post_edit_count" => 0
    })
    |> Ash.create(domain: PhpBB.Domain)
  end

  def create_post_text_record(post_id, topic_title, post_text_content) do
    PhpBB.PostsText
    |> Ash.Changeset.for_create(:create, %{
      "post_id" => post_id,
      "post_subject" => topic_title,
      "post_text" => post_text_content
    })
    |> Ash.create(domain: PhpBB.Domain)
  end

  def update_topic_pointers(topic, post_id) do
    topic
    |> Ash.Changeset.for_update(:update, %{
      "first_post_id" => post_id,
      "last_post_id" => post_id
    })
    |> Ash.update(domain: PhpBB.Domain)
  end

  def update_forum_last_post(forum_record, post_id) do
    forum_record
    |> Ash.Changeset.for_update(:update, %{
      "forum_last_post_id" => post_id
    })
    |> Ash.update(domain: PhpBB.Domain)
  end
end
