defmodule SambaWeb.Presence do
  use Phoenix.Presence,
      otp_app: :samba,
      pubsub_server: Samba.PubSub
end