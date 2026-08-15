defmodule SambaWeb.PageController do
  use SambaWeb, :controller


  alias Samba.Core.Page

  plug :put_view, html: SambaWeb.PageHTML, md: SambaWeb.PageMD

  def show(conn, %{"page" => name}) do
    case Page.by_title(name) do
      {:ok, page} ->
        conn
        |> SEO.assign(page)
        |> render(:show, data: page)

      {:error, _} ->
        conn
        |> put_flash(:error, "Page not found")
        |> redirect(to: ~p"/")
    end
  end

  def show(conn, _) do
    conn
    |> put_flash(:error, "Page not found")
    |> redirect(to: ~p"/")
  end
end
