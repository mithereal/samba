defmodule SambaWeb.NewPostLive do
  use SambaWeb, :live_view
  use CKEditor5
  use SambaWeb.LiveTracking

  require Logger
  import Ash.Query

  alias CKEditor5.Preset
  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  def mount(%{"id" => id}, _session, socket) do
    topic_id = String.to_integer(id)

    # Fetch topic and its related forum
    topic = Ash.get!(PhpBB.Topics, topic_id, domain: PhpBB.Domain)
    forum = Ash.get!(PhpBB.Forums, topic.forum_id, domain: PhpBB.Domain)
    current_user = socket.assigns[:current_user]
    poster_id = current_user.phpbb_user_id

    # Evaluate reply permissions based on phpBB2 authorization system
    unless evaluate_reply_permissions(forum, topic, current_user) do
      raise RuntimeError, message: "You are not authorized to reply to this topic."
    end

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
        domain: PhpBB.Domain,
        params: %{
          "topic_id" => topic_id,
          "forum_id" => forum.forum_id,
          "poster_id" => poster_id,
          "post_time" => post_time,
          "post_username" => "",
          "poster_ip" => "00000000",
          "enable_bbcode" => 1,
          "enable_smilies" => 1,
          "enable_sig" => 1,
          "enable_html" => 0,
          "post_edit_time" => 0,
          "post_edit_count" => 0
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:topic, topic)
      |> assign(:forum, forum)
      |> assign(:poster_id, poster_id)
      |> assign(:topic_id, topic_id)
      |> assign(:forum_id, forum.forum_id)
      |> assign(:page_title, "Post Reply")
      |> assign(:preset, preset)
      |> assign(:form, form)

    {:ok, socket}
  end

  defp evaluate_reply_permissions(forum, topic, user) do
    user_level = Map.get(user, :user_level, 0) || 0

    # Locked topics check: only admins (1) or mods (2) can reply to locked topics (topic_status == 1)
    if topic.topic_status == 1 and user_level not in [1, 2] do
      false
    else
      # Administrators (1) and Moderators (2) bypass restrictions globally
      if user_level in [1, 2] do
        true
      else
        reply_auth = forum.auth_reply || 0
        check_auth_level(forum, reply_auth, user, :auth_reply)
      end
    end
  end

  defp check_auth_level(forum, auth_val, user, permission_field) do
    user_level = Map.get(user, :user_level, 0) || 0

    cond do
      # AUTH_ALL (0): Everyone can reply
      auth_val == 0 ->
        true

      # AUTH_REG (1): Any registered user can reply
      auth_val == 1 ->
        user_level >= 0

      # AUTH_MOD (3): Only board moderators or admins
      auth_val == 3 ->
        user_level in [1, 2]

      # AUTH_ADMIN (5): Only administrators
      auth_val == 5 ->
        user_level == 1

      # AUTH_ACL (2): Custom Access Control List check via phpbb_user_group and phpbb_auth_access
      auth_val == 2 ->
        check_acl_permission(forum, user, permission_field)

      true ->
        false
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
          Logger.error("Failed to evaluate ACL permissions for reply: #{inspect(e)}")
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
        <.form for={@form} phx-submit="save" phx-change="validate">
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

          <div class="mb-4">
            <div class="[&_.ck-editor__editable]:!min-h-[20rem]">
              <.ckeditor
                id="content-editor"
                field={@form[:post_text]}
                preset={@preset}
                type="classic"
              />
            </div>
          </div>

          <div class="flex flex-row justify-end space-x-2 mt-4">
            <.link
              navigate={~p"/topics/#{@topic_id}"}
              class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
            >
              Cancel
            </.link>
            <.button
              type="submit"
              class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium"
            >
              Submit Reply
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

  def handle_event("save", %{"form" => params}, socket) do
    poster_id = socket.assigns.poster_id
    forum_id = socket.assigns.forum_id
    can_post_sticky = socket.assigns.can_post_sticky
    can_post_announce = socket.assigns.can_post_announce
    post_time = System.os_time(:second)

    forum_record = socket.assigns.forum

    topic_title = String.trim(params["topic_title"] || "")
    post_text_content = String.trim(params["post_text"] || "")

    if String.length(topic_title) < 1 || String.length(post_text_content) < 1 do
      form = AshPhoenix.Form.validate(socket.assigns.form, params)

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

      result =
        Samba.Repo.transaction(fn ->
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
                   "topic_type" => topic_type,
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
                   "poster_ip" => "127.0.0.1",
                   "enable_bbcode" => enable_bbcode,
                   "enable_html" => enable_html,
                   "enable_smilies" => enable_smilies,
                   "enable_sig" => 1,
                   "post_edit_time" => 0,
                   "post_edit_count" => 0
                 })
                 |> Ash.create(domain: PhpBB.Domain),
               {:ok, _post_text} <-
                 PhpBB.PostsText
                 |> Ash.Changeset.for_create(:create, %{
                   "post_id" => post.post_id,
                   "post_subject" => topic_title,
                   "post_text" => post_text_content
                 })
                 |> Ash.create(domain: PhpBB.Domain),
               {:ok, updated_topic} <-
                 topic
                 |> Ash.Changeset.for_update(:update, %{
                   "first_post_id" => post.post_id,
                   "last_post_id" => post.post_id
                 })
                 |> Ash.update(domain: PhpBB.Domain),
               {:ok, _updated_forum} <-
                 forum_record
                 |> Ash.Changeset.for_update(:update, %{
                   "forum_last_post_id" => post.post_id
                 })
                 |> Ash.update(domain: PhpBB.Domain) do
            updated_topic
          else
            {:error, reason} ->
              Samba.Repo.rollback(reason)

            error ->
              Samba.Repo.rollback(error)
          end
        end)

      case result do
        {:ok, updated_topic} ->
          {:noreply,
           socket
           |> put_flash(:info, "Topic and post created successfully!")
           |> push_navigate(to: ~p"/topics/#{updated_topic.topic_id}")}

        {:error, reason} ->
          Logger.error("TRANSACTION FAILED: #{inspect(reason, pretty: true)}")

          form =
            socket.assigns.form
            |> AshPhoenix.Form.validate(params)

          {:noreply,
           socket
           |> put_flash(:error, "Failed to create topic. Check server logs for details.")
           |> assign(form: to_form(form))}
      end
    end
  end
end
