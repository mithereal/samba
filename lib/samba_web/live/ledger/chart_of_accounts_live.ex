defmodule SambaWeb.Ledger.ChartOfAccountsLive do
  use SambaWeb, :live_view

  on_mount {SambaWeb.LiveUserAuth, :live_user_required}
  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.ledger flash={@flash} current_user={@current_user} uri={@uri}>
      <Cinder.Table.table resource={Samba.Ledger.Account} actor={@current_user}>
        <:col :let={account} field="identifer" label="Code" filter>{account.identifier}</:col>
        <:col :let={account} field="name" label="Name">{account.name}</:col>
        <:col :let={account} field="currency" label="currency">{account.currency}</:col>
        <:col :let={account} field="nature" label="Nature">{account.nature}</:col>
      </Cinder.Table.table>
    </Layouts.ledger>
    """
  end
end
