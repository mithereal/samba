defmodule CapsuleWeb.Server do
  use Spaceboy.Server, otp_app: :samba

  middleware Spaceboy.Middleware.Logger

  middleware Spaceboy.Middleware.RequestId

  middleware CapsuleWeb.Router
end
