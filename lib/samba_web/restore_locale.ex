defmodule SambaWeb.RestoreLocale do
  @moduledoc """
  Restore locale upon LiveView mount.
  """

  def on_mount(:default, _params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(SambaWeb.Gettext, locale)
    Cldr.put_locale(locale)

    {:cont, socket}
  end

  # catch-all case
  def on_mount(:default, _params, _session, socket), do: {:cont, socket}
end
