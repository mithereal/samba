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
          "forum_desc" => ""
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

  def handle_event("validate", %{"category_id" => category_id}, socket) do
    {:noreply, assign(socket, :selected_category_id, category_id)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <div class="shadow-xl rounded-lg overflow-hidden border border-gray-300 dark:border-gray-700 bg-gray-200 dark:bg-gray-900/80 backdrop-blur-md">
        <div class="w-2/3 mx-auto px-4 sm:px-6 lg:px-2 py-8 text-gray-100">
          <.form for={@form} phx-submit="save" phx-change="validate">
            <.select
              id="baseui-select-hero"
              name="form[cat_id]"
              label="Categories"
              placeholder="Select Category"
              class="flex flex-col items-start gap-1 mb-4"
              label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
              trigger_class="flex h-8 min-w-40 items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
              value_class="data-[placeholder]:text-neutral-500 dark:data-[placeholder]:text-neutral-400"
              icon_class="flex items-center"
              positioner_class="outline-hidden select-none z-10"
              popup_class="group min-w-[var(--anchor-width)] origin-[var(--transform-origin)] py-1 bg-clip-padding border border-neutral-950 bg-white text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[side=none]:translate-y-px data-[side=none]:min-w-[calc(var(--anchor-width)+1.75rem)] data-[side=none]:data-[ending-style]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[side=none]:data-[starting-style]:scale-100 data-[side=none]:data-[starting-style]:opacity-100 data-[side=none]:data-[starting-style]:transition-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
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
            <.text_field
              id="name"
              field={@form[:forum_name]}
              space="small"
              placeholder="Name"
              variant="default"
              class="mb-4"
              color="white"
            />
            <div class="mb-4"></div>

          <div>
                <.radio_card field={@form[:topic_status]} space="small" cols="two" color="misc" size="extra_small" variant="shadow" color="info" field={@form[:forum_status]}>
                  <:radio
                    value="0"
                    title="Unlocked"
                    description="Members can freely reply and participate in this discussion."
                    icon="hero-lock-open"
                  />
                  <:radio
                    value="1"
                    title="Locked"
                    description="Discussion is closed; only moderators can reply."
                    icon="hero-lock-closed"
                  />
                </.radio_card>
              </div>


            <div class="[&_.ck-editor__editable]:!min-h-[56rem] mt-4 mb-4">
              <.ckeditor
                id="content-editor"
                field={@form[:forum_desc]}
                preset={@preset}
                type="classic"
              />
            </div>

    <div class="flex flex-row">
                <.radio_card  space="small" cols="one" size="extra_small" variant="bordered" color="success" field={@form[:auth_announce]}>
                  <:radio
                    value="announcement"
                    title="Announcement"
                    description="Important global or forum-specific notice pinned at the top."
                    icon="hero-megaphone"
                  />
      </.radio_card>
                <.radio_card space="small" cols="one" size="extra_small" variant="bordered" color="success" field={@form[:auth_sticky]}>
                  <:radio
                    value="sticky"
                    title="Sticky"
                    description="Stays fixed near the top of the topic list for high visibility."
                    icon="hero-bookmark"
                  />
                </.radio_card>
              </div>
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
      |> Map.put("cat_id", socket.assigns.cat_id)
      |> Map.put("forum_name", socket.assigns.forum_name)
      |> Map.put("forum_desc", socket.assigns.forum_desc)

    form = AshPhoenix.Form.validate(socket.assigns.form, merged_params)
    {:noreply, assign(socket, form: to_form(form))}
  end

  def handle_event("save", %{"form" => params}, socket) do
    submission_params =
      params
      |> Map.put("cat_id", socket.assigns.cat_id)
      |> Map.put("forum_name", socket.assigns.forum_name)
      |> Map.put("forum_desc", socket.assigns.forum_desc)

    case AshPhoenix.Form.submit(socket.assigns.form, params: submission_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Forum created successfully!")
         |> push_navigate(to: ~p"/forums")}

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
        data -> data.forum_order || 0
      end

    max_order + 1
  end
end
