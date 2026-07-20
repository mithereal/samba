defmodule PhpBB.Sessions do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_sessions"
    repo Samba.Repo
  end

  actions do
    default_accept [:session_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :session_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :session_user_id
      end
    end

    attribute :session_start, :string do
      allow_nil? true
      public? true
    end

    attribute :session_time, :string do
      allow_nil? true
      public? true
    end

    attribute :session_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :session_page, :string do
      allow_nil? true
      public? true
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
