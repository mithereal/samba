defmodule PhpBB.SessionsKeys do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_sessions_keys"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:phpbb_sessions_keys]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:phpbb_sessions_keys)

    attribute :user_id, :integer do
      allow_nil? true
      public? true
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
