defmodule SambaWeb.Accounts.Groups.EditLive do
  use SambaWeb, :live_view

  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.account_groups current_user={@current_user} flash={@flash} uri={@uri}>
      <SambaWeb.Accounts.Groups.Form.group_form form={@form} />
    </Layouts.account_groups>
    """
  end

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    socket
    |> assign(:record_id, id)
    |> assign(:resource, Samba.Accounts.Group)
    |> assign_query_opts()
    |> assign_attributes()
    |> assign_form()
    |> ok()
  end
end
