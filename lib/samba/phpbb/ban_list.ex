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
    integer_primary_key(:ban_id)

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :ban_userid
      end

      belongs_to :moderator, PhpBB.Users do
        destination_attribute :group_moderator
      end

      belongs_to :single_user, PhpBB.Users do
        destination_attribute :group_single_user
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
