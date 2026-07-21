defmodule SambaWeb.FaqLive do
  use SambaWeb, :live_view
  alias PhpBB.FaqItem

  def mount(_params, _session, socket) do
    faq_items = FaqItem.read_all!()

    grouped_faqs =
      faq_items
      |> Enum.group_by(& &1.variable)
      |> Enum.map(fn {variable, items} ->
        {variable, Enum.group_by(items, & &1.section)}
      end)
      |> Enum.into(%{})

    {:ok, assign(socket, grouped_faqs: grouped_faqs)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-12">
      <h1 class="text-3xl font-bold tracking-tight text-zinc-900 mb-8">Documentation & FAQs</h1>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <!-- Sticky Table of Contents Sidebar -->
        <div class="lg:col-span-1">
          <div class="sticky top-8 bg-white shadow-sm ring-1 ring-zinc-900/5 rounded-xl p-6">
            <h2 class="text-sm font-semibold uppercase tracking-wider text-zinc-900 mb-4">
              Table of Contents
            </h2>
            <nav class="space-y-6 text-sm">
              <%= for {variable_name, sections} <- @grouped_faqs do %>
                <div>
                  <a
                    href={"##{variable_name}"}
                    class="font-mono font-medium text-indigo-600 hover:text-indigo-800 block mb-2"
                  >
                    ${variable_name}[]
                  </a>
                  <ul class="space-y-1.5 pl-3 border-l border-zinc-200">
                    <%= for {section_title, _items} <- sections do %>
                      <% section_id = slugify("#{variable_name}-#{section_title}") %>
                      <li>
                        <a
                          href={"##{section_id}"}
                          class="text-zinc-600 hover:text-zinc-900 block truncate transition-colors"
                        >
                          {section_title}
                        </a>
                      </li>
                    <% end %>
                  </ul>
                </div>
              <% end %>
            </nav>
          </div>
        </div>

        <!-- Main Content Area -->
        <div class="lg:col-span-3 space-y-16">
          <%= for {variable_name, sections} <- @grouped_faqs do %>
            <div
              id={variable_name}
              class="scroll-mt-8 border-t border-zinc-200 pt-8 first:border-none first:pt-0"
            >
              <div class="flex items-center gap-3 mb-6">
                <span class="inline-flex items-center rounded-md bg-indigo-50 px-2.5 py-1 text-xs font-mono font-medium text-indigo-700 ring-1 ring-inset ring-indigo-600/10">
                  ${variable_name}[]
                </span>
                <h2 class="text-xl font-bold tracking-tight text-zinc-900 capitalize">
                  {variable_name} Archive
                </h2>
              </div>

              <div class="space-y-8">
                <%= for {section_title, items} <- sections do %>
                  <% section_id = slugify("#{variable_name}-#{section_title}") %>
                  <div
                    id={section_id}
                    class="scroll-mt-8 bg-white shadow-sm ring-1 ring-zinc-900/5 rounded-xl p-6 sm:p-8"
                  >
                    <h3 class="text-lg font-semibold text-indigo-600 border-b border-zinc-100 pb-3 mb-6">
                      {section_title}
                    </h3>

                    <dl class="space-y-6">
                      <%= for item <- items do %>
                        <div class="border-b border-zinc-100 pb-6 last:border-none last:pb-0">
                          <dt class="text-base font-semibold text-zinc-900">
                            {item.question}
                          </dt>
                          <dd class="mt-2 text-base text-zinc-600 leading-relaxed">
                            {raw(item.answer)}
                          </dd>
                        </div>
                      <% end %>
                    </dl>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
    |> String.trim("-")
  end
end
