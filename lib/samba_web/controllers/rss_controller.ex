defmodule SambaWeb.RSSController do
  use SambaWeb, :controller

  require Ash.Query
  plug :put_layout, false

  def index(conn, %{"topic_id" => topic_id}) do

    forum =
      PhpBB.Forums
      |> Ash.Query.filter(forum_id == ^topic_id)
      |> Ash.read_one!(domain: PhpBB.Domain)

    data =
      PhpBB.Topics
      |> Ash.Query.filter(topic_id == ^topic_id )
      |> Ash.Query.sort(topic_time: :desc)
      |> Ash.Query.sort(topic_time: :desc)
      |> Ash.Query.load([:poster, :last_post]) #
      |> Ash.read!(domain: PhpBB.Domain)
    conn
    |> put_resp_content_type("application/rss+xml")
    |> render( "rss.xml", articles: data, host: conn.host, port: conn.port)
  end
end
