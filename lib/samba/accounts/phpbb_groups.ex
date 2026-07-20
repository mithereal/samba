defmodule PhpBB.Groups do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_groups"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:group_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:group_id)

    attribute :group_name, :string do
      allow_nil? true
      public? true
    end

    attribute :group_type, :integer do
      allow_nil? true
      public? true
    end

    attribute :group_description, :string do
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
