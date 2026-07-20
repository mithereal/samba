defmodule PhpBB.UserGroup do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_user_group"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:group_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key(:group_id)

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
