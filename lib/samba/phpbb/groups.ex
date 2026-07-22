defmodule PhpBB.Groups do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_groups"
    repo Samba.Repo
  end

  actions do
    default_accept [:group_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :group_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :group_name, :string do
      allow_nil? false
      public? true
    end

    attribute :group_moderator, :integer do
      allow_nil? false
      public? true
      default 0
    end

    attribute :group_single_user, :integer do
      allow_nil? false
      public? true
      default 0
    end

    attribute :group_type, :integer do
      allow_nil? false
      public? true
      default 1
    end

    attribute :group_description, :string do
      allow_nil? true
      public? true
    end

    relationships do
      belongs_to :moderator, PhpBB.Users do
        source_attribute :group_moderator
        destination_attribute :user_id
        attribute_type :integer
      end
    end
  end
end
