defmodule PhpBB.Groups do
  use Ash.Resource,
    domain: PhpBB,
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
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    attribute :group_name, :string do
      allow_nil? true
      public? true
    end

    attribute :group_single_user, :integer do
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

    relationships do
      belongs_to :moderator, PhpBB.Users do
        destination_attribute :group_moderator
      end
    end
  end
end
