defmodule PhpBB.Sessions do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_sessions"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :session_id,
        :session_user_id,
        :session_start,
        :session_time,
        :session_ip,
        :session_page,
        :session_logged_in,
        :session_admin
      ]
    end
  end

  attributes do
    attribute :session_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :session_user_id, :integer do
      public? true
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
        source_attribute :session_user_id
        attribute_type :integer
      end
    end

    attribute :session_start, :string do
      allow_nil? true
      public? true
      description "the exact Unix timestamp when a user's session was initially created"
    end

    attribute :session_time, :string do
      allow_nil? true
      public? true

      description "a timestamp column located in the phpbb_sessions table that records the exact Unix timestamp of a user's last active request on the board."
    end

    attribute :session_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :session_page, :string do
      allow_nil? true
      public? true
      description "the numeric identifier of the page or script the user is currently viewing."
    end

    attribute :session_logged_in, :string do
      allow_nil? true
      public? true
    end

    attribute :session_admin, :string do
      allow_nil? true
      public? true
    end
  end
end
