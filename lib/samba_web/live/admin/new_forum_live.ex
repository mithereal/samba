defmodule SambaWeb.Admin.New.Forum.Live do
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

    category_options =
      Enum.map(categories, fn category ->
        %{
          value: to_string(category.cat_id),
          label: category.cat_title
        }
      end)

    form =
      PhpBB.Forums
      |> AshPhoenix.Form.for_create(:create,
        as: "form",
        params: %{
          "forum_name" => "",
          "forum_desc" => "",
          "forum_status" => false,
          "prune_enable" => false,
          "prune_days" => "",
          "prune_freq" => ""
        }
      )
      |> to_form()

    socket =
      socket
      |> assign(:page_title, "Add Forum")
      |> assign(:preset, preset)
      |> assign(:form, form)
      |> assign(:categories, category_options)
      |> assign(:selected_category_id, List.first(category_options).value)
      |> assign(:forum_order, next_order)

    {:ok, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    category_id = params["cat_id"] || socket.assigns.selected_category_id

    normalized_params =
      params
      |> Map.update("prune_enable", false, fn val -> val in ["true", "1", "on", true] end)
      |> cast_numeric_params(["prune_days", "prune_freq", "forum_order"])

    form = AshPhoenix.Form.validate(socket.assigns.form, normalized_params)

    {:noreply,
     socket
     |> assign(:selected_category_id, category_id)
     |> assign(:form, to_form(form))}
  end

  def handle_event("save", %{"form" => params}, socket) do
    normalized_params =
      params
      |> Map.update("prune_enable", false, fn val -> val in ["true", "1", "on", true] end)
      |> cast_numeric_params(["prune_days", "prune_freq", "forum_order"])

    submission_params =
      normalized_params
      |> Map.put_new("cat_id", socket.assigns.selected_category_id)
      |> Map.put("forum_order", socket.assigns.forum_order)

    case AshPhoenix.Form.submit(socket.assigns.form, params: submission_params) do
      {:ok, forum} ->
        if submission_params["prune_enable"] == true do
          create_forum_prune(forum.forum_id, submission_params)
        end

        {:noreply,
         socket
         |> put_flash(:info, "Forum saved successfully!")
         |> push_navigate(to: ~p"/settings/forums")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  defp cast_numeric_params(params, keys) do
    Enum.reduce(keys, params, fn key, acc ->
      case Map.get(acc, key) do
        val when val == "" or val == nil ->
          Map.put(acc, key, nil)

        val when is_binary(val) ->
          case Integer.parse(val) do
            {int, _} -> Map.put(acc, key, int)
            :error -> Map.put(acc, key, nil)
          end

        _ ->
          acc
      end
    end)
  end

  defp sanitize_empty_numeric_fields(params) do
    params
    |> Map.update("prune_days", nil, fn
      val when val == "" or val == nil -> nil
      val -> val
    end)
    |> Map.update("prune_freq", nil, fn
      val when val == "" or val == nil -> nil
      val -> val
    end)
  end

  defp create_forum_prune(forum_id, params) do
    days = parse_int(params["prune_days"])
    freq = parse_int(params["prune_freq"])

    if days && freq do
      Ash.create!(PhpBB.ForumPrune,
        domain: PhpBB.Domain,
        action: :create,
        input: %{
          forum_id: forum_id,
          prune_days: days,
          prune_freq: freq
        }
      )
    end
  end

  defp parse_int(val) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} -> int
      :error -> nil
    end
  end

  defp parse_int(val) when is_integer(val), do: val
  defp parse_int(_), do: nil

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
        <div class="w-3/4 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
          <.form for={@form} phx-submit="save" phx-change="validate">
            <!-- Category Selection -->
            <.select
              id="baseui-select-hero"
              name="form[cat_id]"
              label="Category"
              placeholder="Select Category"
              class="flex flex-col items-start gap-1 mb-4"
              label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
              trigger_class="flex h-8 min-w-40 items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
              value_class="data-[placeholder]:text-neutral-500 dark:data-[placeholder]:text-neutral-400"
              icon_class="flex items-center"
              positioner_class="outline-hidden select-none z-10"
              popup_class="group min-w-[var(--anchor-width)] origin-[var(--transform-origin)] py-1 bg-clip-padding border border-neutral-950 bg-white text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out dark:border-white dark:bg-neutral-950 dark:text-white"
              item_class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-1.5 pr-4 pl-2.5 text-sm outline-hidden select-none data-[highlighted]:bg-neutral-950 data-[highlighted]:text-white dark:data-[highlighted]:bg-white dark:data-[highlighted]:text-neutral-950"
              item_indicator_class="col-start-1"
              item_text_class="col-start-2"
              options={@categories}
              value={@selected_category_id}
            >
              <:icon>
                <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
                  <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
                </svg>
              </:icon>
              <:item_indicator>
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 16 16"
                  fill="none"
                  stroke="currentColor"
                  class="block"
                >
                  <path d="m2.5 8.5 4 4 7-9" />
                </svg>
              </:item_indicator>
            </.select>

            <!-- Forum Name -->
            <.text_field
              id="name"
              field={@form[:forum_name]}
              space="small"
              label="Forum Name"
              placeholder="Enter forum name..."
              variant="default"
              class="mb-4"
              color="white"
            />

            <!-- Forum Status (Radio Fields) -->
            <div class="mb-4 flex flex-col gap-2">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white mb-1">Forum Status</label>
              <.radio_field
                id="forum_status_unlocked"
                field={@form[:forum_status]}
                value={false}
                label="Unlocked (Members can freely reply and participate)"
                color="info"
                space="small"
              />
              <.radio_field
                id="forum_status_locked"
                field={@form[:forum_status]}
                value={true}
                label="Locked (Discussion is closed; only moderators can reply)"
                color="info"
                space="small"
              />
            </div>

            <!-- Forum Description (CKEditor) -->
            <div class="mt-4 mb-4">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white mb-1">Forum Description</label>
              <div class="[&_.ck-editor__editable]:!min-h-[24rem]">
                <.ckeditor
                  id="content-editor"
                  field={@form[:forum_desc]}
                  preset={@preset}
                  type="classic"
                />
              </div>
            </div>

            <!-- Prune Enable Checkbox -->
            <div class="mb-4">
              <.checkbox_field
                id="prune_enable"
                field={@form[:prune_enable]}
                label="Enable Prune"
                space="small"
                color="white"
              />
            </div>

            <!-- Prune Days -->
            <div class="mb-4">
              <.text_field
                id="prune_days"
                label="Remove topics that have not been posted to in X Days"
                field={@form[:prune_days]}
                space="small"
                placeholder=""
                variant="default"
                color="white"
              />
            </div>

            <!-- Prune Frequency -->
            <div class="mb-4">
              <.text_field
                id="prune_freq"
                label="Check for Topic Age every X Days"
                field={@form[:prune_freq]}
                space="small"
                placeholder=""
                variant="default"
                color="white"
              />
            </div>

            <div class="flex flex-row justify-end space-x-2 mt-6">
              <.link
                navigate={~p"/settings/forums"}
                class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Cancel
              </.link>
              <.button
                type="submit"
                class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium"
              >
                Create Forum
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp get_next_order do
    max_order =
      PhpBB.Forums
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(forum_order: :desc)
      |> Ash.Query.limit(1)
      |> Ash.read!(domain: PhpBB.Domain)
      |> List.first()
      |> case do
        nil -> 0
        data -> data.forum_order || 0
      end

    max_order + 1
  end
end
