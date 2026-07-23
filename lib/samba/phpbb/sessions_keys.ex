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
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :phpbb_sessions_keys,
        :user_id,
        :last_ip,
        :last_login
      ]
    end
  end

  attributes do
    attribute :phpbb_sessions_keys, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :user_id, :integer do
      public? true
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
        source_attribute :user_id
        attribute_type :integer
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
