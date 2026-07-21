defmodule PhpBB.SessionsKeys do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_sessions_keys"
    repo Samba.Repo
  end

  actions do
    default_accept [:phpbb_sessions_keys]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :phpbb_sessions_keys, :integer do
      writable? false
      generated? true
      primary_key? true
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
      end
    end

    attribute :last_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :last_login, :string do
      allow_nil? true
      public? true
    end
  end
end
