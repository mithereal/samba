defmodule SambaWeb.FaqImportLive do
  use SambaWeb, :live_view
  alias Samba.Util.FaqImporter

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{"content" => ""}))
      |> assign(:imported_count, nil)
      |> assign(:error, nil)

    {:ok, socket}
  end

  def handle_event("validate", %{"content" => content}, socket) do
    {:noreply,
     assign(socket, form: to_form(%{"content" => content}), imported_count: nil, error: nil)}
  end

  def handle_event("import", %{"content" => content}, socket) do
    case FaqImporter.import_from_php_string(content) do
      {:ok, count} ->
        {:noreply,
         socket
         |> assign(:imported_count, count)
         |> assign(:error, nil)}

      {:error, reason} ->
        {:noreply, assign(socket, :error, inspect(reason))}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto px-4 py-12">
      <div class="bg-white shadow-sm ring-1 ring-zinc-900/5 rounded-xl p-6 sm:p-8">
        <h1 class="text-2xl font-bold tracking-tight text-zinc-900 mb-2">
          Import Multi-Block Language File
        </h1>
        <p class="text-sm text-zinc-600 mb-6">
          Paste your legacy PHP language file below. The parser automatically detects all array variable blocks (e.g. <code class="bg-zinc-100 px-1 py-0.5 rounded text-zinc-800">$faq[]</code>, <code class="bg-zinc-100 px-1 py-0.5 rounded text-zinc-800">$forum[]</code>) and section headers simultaneously.
        </p>

        <%= if @imported_count do %>
          <div class="mb-6 rounded-md bg-emerald-50 p-4 ring-1 ring-emerald-600/20">
            <p class="text-sm font-medium text-emerald-800">
              Successfully processed and imported <strong>{@imported_count}</strong>
              items across multiple blocks!
            </p>
          </div>
        <% end %>

        <%= if @error do %>
          <div class="mb-6 rounded-md bg-rose-50 p-4 ring-1 ring-rose-600/20">
            <p class="text-sm font-medium text-rose-800">
              Import failed: {@error}
            </p>
          </div>
        <% end %>

        <.form for={@form} phx-submit="import" phx-change="validate" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-zinc-700">Raw PHP File Contents</label>
            <div class="mt-1">
              <textarea
                name="content"
                rows="16"
                class="block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 font-mono text-xs border p-3"
                placeholder="Paste complete php file contents here containing multiple $faq[], $forum[] blocks..."
              >{@form[:content].value}</textarea>
            </div>
          </div>

          <div class="flex justify-end">
            <button
              type="submit"
              class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            >
              Parse & Import All Blocks
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
