defmodule SambaWeb.RSSController do
  use SambaWeb, :controller

  require Ash.Query
  plug :put_layout, false

  def index(conn, %{"forum_id" => forum_id}) do
    articles =
      PhpBB.Topics
      |> Ash.Query.filter(forum_id == ^forum_id)
      |> Ash.Query.sort(topic_time: :desc)
      #
      |> Ash.Query.load([:poster, :last_post])
      |> Ash.read!(domain: PhpBB.Domain)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> render("rss.xml", articles: articles, host: conn.host, port: conn.port)
  end
end
