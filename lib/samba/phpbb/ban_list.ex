defmodule PhpBB.BanList do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_banlist"
    repo Samba.Repo
  end

  actions do
    default_accept [:ban_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :ban_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :ban_userid, :integer do
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
        source_attribute :ban_userid
        attribute_type :integer
      end
    end

    attribute :ban_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :ban_email, :string do
      allow_nil? true
      public? true
    end
  end
end
