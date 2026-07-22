defmodule SambaWeb.PostMD do
  @behaviour SEO.LLMs
  use SambaWeb, :verified_routes

  # Phoenix view function — called when format is "md"
  def show(%{post: post}) do
    """
    # #{post.title}

    #{post.body}
    """
  end

  # llms.txt entry — called by your Provider with the current conn
  @impl SEO.LLMs
  def entry(post, conn) do
    SEO.LLMs.Entry.build(
      section: "Posts",
      title: post.title,
      url: url(conn, ~p"/posts/#{post}"),
      description: post.summary
    )
  end
end
