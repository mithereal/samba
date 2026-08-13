defmodule CapsuleWeb.Controller do
  use Spaceboy.Controller,
    root: "lib/capsule_web/templates"

  alias Spaceboy.Conn
  alias Spaceboy.PeerCert
  require Ash.Query
  require Logger

  @doc ~S"""
  Index page with Gemini response constructed as string
  """
  def index(conn) do
    gemini(conn, """
    # The Samba

    => /forums Forums
    => /forum Forum
    => /topics Topics
    => /topic Topic

    """)
  end

  @doc ~S"""
  Page with URL parameter
  """
  def forums(conn) do
    render(conn, "forums.gmi", title: "Forums")
  end

  def forum(conn) do
    render(conn, "forum.gmi", title: "Forum")
  end

  @doc ~S"""
  Page with URL parameter
  """
  def topics(conn) do
    render(conn, "topics.gmi", title: "topics")
  end

  def topic(conn) do
    render(conn, "topic.gmi", title: "topic")
  end
end
