defmodule PhpBB.UserGroup do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_user_group"
    repo Samba.Repo
  end

  actions do
    default_accept [:group_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :group_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
      end

      belongs_to :user_pending, PhpBB.Users do
        destination_attribute :user_pending
      end
    end
  end
end
