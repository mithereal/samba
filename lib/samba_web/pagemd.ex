defmodule SambaWeb.PageMD do
  @behaviour SEO.LLMs
  use SambaWeb, :verified_routes

  # Phoenix view function — called when format is "md"
  def show(%{page: page}) do
    """
    # #{page.title}

    #{page.body}
    """
  end

  # llms.txt entry — called by your Provider with the current conn
  @impl SEO.LLMs
  def entry(page, conn) do
    SEO.LLMs.Entry.build(
      section: "Page",
      title: page.title,
      url: url(conn, ~p"/page/#{page}"),
      description: page.summary
    )
  end
end
