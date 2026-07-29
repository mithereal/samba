defmodule SambaWeb.RSSXML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use SambaWeb, :html

  def pub_link(nil), do: "127.0.0.1"
  def pub_link(articles) when is_list(articles), do: List.first(articles) |> pub_link()
  def pub_link(article), do: "127.0.0.1"

  def pub_date(nil), do: ""
  def pub_date(articles) when is_list(articles), do: List.first(articles) |> pub_date()
  def pub_date(article), do: format_rfc822(article.topic_time)

  def format_rfc822(unix_timestamp) do
    {:ok, datetime} = DateTime.from_unix(unix_timestamp)

    # RFC 822 format: "Tue, 28 Jul 2026 19:46:55 +0000"
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%M:%S %z")
  end

  def format_post(data) do
    data
  end

  # def format_rfc822(date_time), do: Calendar.strftime(date_time, "%a, %d %b %Y %H:%M:%S %Z")

  embed_templates "rss_xml/*"
end
