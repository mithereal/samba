defmodule Samba.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Samba.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:Samba, :token_signing_secret)
  end
end
