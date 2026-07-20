defmodule PhpBB.BanList do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_banlist"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:ban_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:ban_id)

    attribute :ban_userid, :integer do
      allow_nil? true
      public? true
    end

    attribute :ban_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :ban_email, :string do
      allow_nil? true
      public? true
    end

    attribute :group_moderator, :integer do
      allow_nil? true
      public? true
    end

    attribute :group_single_user, :integer do
      allow_nil? true
      public? true
    end
  end
end
