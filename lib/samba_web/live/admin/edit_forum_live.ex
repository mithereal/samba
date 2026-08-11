defmodule SambaWeb.Admin.Edit.Forum.Live do
  use SambaWeb, :live_view
  use CKEditor5

  require Logger
  require Ash.Query

  alias CKEditor5.Preset

  def mount(%{"id" => id}, _session, socket) do
    forum =
      PhpBB.Forums
      |> Ash.get!(id, domain: PhpBB.Domain)

    existing_prune =
      PhpBB.ForumPrune
      |> Ash.Query.filter(forum_id == ^forum.forum_id)
      |> Ash.read_one!(domain: PhpBB.Domain)

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
      forum
      |> AshPhoenix.Form.for_update(:update,
        as: "form",
        domain: PhpBB.Domain
      )
      |> to_form()

    socket =
      socket
      |> assign(:page_title, "Edit Forum")
      |> assign(:preset, preset)
      |> assign(:form, form)
      |> assign(:forum, forum)
      |> assign(:categories, category_options)
      |> assign(:selected_category_id, to_string(forum.cat_id))
      |> assign(:prune_days, (existing_prune && to_string(existing_prune.prune_days)) || "")
      |> assign(:prune_freq, (existing_prune && to_string(existing_prune.prune_freq)) || "")

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    form_params = Map.get(params, "form", %{})
    prune_days = Map.get(params, "prune_days", socket.assigns.prune_days)
    prune_freq = Map.get(params, "prune_freq", socket.assigns.prune_freq)

    normalized_params =
      form_params
      |> Map.update("prune_enable", 0, fn val ->
        if val in ["true", "1", "on", true], do: 1, else: 0
      end)
      |> cast_numeric_params(["forum_status", "forum_order"])

    form = AshPhoenix.Form.validate(socket.assigns.form, normalized_params)

    {:noreply,
     socket
     |> assign(form: to_form(form))
     |> assign(
       :selected_category_id,
       form_params["cat_id"] || socket.assigns.selected_category_id
     )
     |> assign(:prune_days, prune_days)
     |> assign(:prune_freq, prune_freq)}
  end

  def handle_event("save", params, socket) do
    form_params = Map.get(params, "form", %{})
    prune_days = Map.get(params, "prune_days", socket.assigns.prune_days)
    prune_freq = Map.get(params, "prune_freq", socket.assigns.prune_freq)

    normalized_params =
      form_params
      |> Map.update("prune_enable", 0, fn val ->
        if val in ["true", "1", "on", true], do: 1, else: 0
      end)
      |> cast_numeric_params(["forum_status", "forum_order"])

    submission_params =
      Map.put_new(normalized_params, "cat_id", socket.assigns.selected_category_id)

    case AshPhoenix.Form.submit(socket.assigns.form, params: submission_params) do
      {:ok, forum} ->
        if submission_params["prune_enable"] == 1 do
          upsert_forum_prune(forum.forum_id, prune_days, prune_freq)
        else
          delete_forum_prune(forum.forum_id)
        end

        {:noreply,
         socket
         |> put_flash(:info, "Forum updated successfully!")
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

  defp upsert_forum_prune(target_forum_id, raw_days, raw_freq) do
    days = parse_int(raw_days)
    freq = parse_int(raw_freq)

    if days && freq do
      existing =
        PhpBB.ForumPrune
        |> Ash.Query.filter(forum_id == ^target_forum_id)
        |> Ash.read_one!(domain: PhpBB.Domain)

      case existing do
        nil ->
          Ash.create!(PhpBB.ForumPrune,
            domain: PhpBB.Domain,
            action: :create,
            input: %{forum_id: target_forum_id, prune_days: days, prune_freq: freq}
          )

        prune_record ->
          Ash.update!(prune_record,
            domain: PhpBB.Domain,
            action: :update,
            input: %{prune_days: days, prune_freq: freq}
          )
      end
    end
  end

  defp delete_forum_prune(target_forum_id) do
    case PhpBB.ForumPrune
         |> Ash.Query.filter(forum_id == ^target_forum_id)
         |> Ash.read_one!(domain: PhpBB.Domain) do
      nil -> :ok
      record -> Ash.destroy!(record, domain: PhpBB.Domain)
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
              trigger_class="flex h-8 min-w-40 items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
              options={@categories}
              value={@selected_category_id}
            />

            <!-- Forum Name -->
            <.text_field
              id="name"
              field={@form[:forum_name]}
              space="small"
              label="Forum Name"
              placeholder="Enter forum name..."
              class="mb-4"
              color="white"
            />

            <!-- Forum Status (Radio Fields) -->
            <div class="mb-4 flex flex-col gap-2">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white mb-1">Forum Status</label>
              <.group_radio
                field={@form[:forum_status]}
                id="forum_status"
                space="small"
                variation="horizontal"
              >
                <:radio
                  value="0"
                  checked={Phoenix.HTML.Form.input_value(@form, :forum_status) in [0, "0", nil]}
                >
                  Unlocked
                </:radio>
                <:radio
                  value="1"
                  checked={Phoenix.HTML.Form.input_value(@form, :forum_status) in [1, "1"]}
                >
                  Locked
                </:radio>
              </.group_radio>
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

            <div class="mb-4 text-neutral-950 dark:text-white font-medium">
              <label class="flex items-center gap-2 cursor-pointer">
                <input type="hidden" name="form[prune_enable]" value="0" />
                <input
                  type="checkbox"
                  name="form[prune_enable]"
                  value="1"
                  checked={Phoenix.HTML.Form.input_value(@form, :prune_enable) == 1}
                  class="rounded border-neutral-950 dark:border-white text-indigo-600 focus:ring-indigo-500 dark:bg-neutral-950"
                />
                <span class="text-sm font-bold text-neutral-950 dark:text-white">Enable Prune</span>
              </label>
            </div>

            <div class="mb-4 max-w-xs">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white mb-1">Remove topics that have not been posted to in X Days</label>
              <input
                type="text"
                name="prune_days"
                value={@prune_days}
                phx-debounce="blur"
                class="flex h-8 w-full rounded-md border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 py-1 text-sm text-neutral-950 dark:text-white shadow-xs focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
              />
            </div>

            <div class="mb-4 max-w-xs">
              <label class="block text-sm font-bold text-neutral-950 dark:text-white mb-1">Check for Topic Age every X Days</label>
              <input
                type="text"
                name="prune_freq"
                value={@prune_freq}
                phx-debounce="blur"
                class="flex h-8 w-full rounded-md border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 py-1 text-sm text-neutral-950 dark:text-white shadow-xs focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
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
                Update Forum
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
