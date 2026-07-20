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
    primary_key(:group_id)

    attribute :user_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :user_pending, :integer do
      allow_nil? true
      public? true
    end
  end
end
