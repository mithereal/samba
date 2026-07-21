defmodule SambaWeb.PageController do
  use SambaWeb, :controller

  def show(conn, %{"page" => name}) do
    case PhpBB.Page.by_name(name) do
      {:ok, page} ->
        render(conn, :show, data: page)

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

  def contact(conn, _params) do
    data = PhpBB.Page.by_name!("contact")
    render(conn, :contact, data: data)
  end

  def donate(conn, _params) do
    data = PhpBB.Page.by_name!("donate")
    render(conn, :donate, data: data)
  end

  def members(conn, _params) do
    data = PhpBB.Page.by_name!("members")
    render(conn, :members, data: data)
  end

  def whats_new(conn, _params) do
    data = PhpBB.Page.by_name!("whats_new")
    render(conn, :whats_new, data: data)
  end

  def donate(conn, _params) do
    data = PhpBB.Page.by_name!("donate")
    render(conn, :donate, data: data)
  end
end
