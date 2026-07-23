defmodule PhpBB.UserGroup do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_user_group"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :group_id,
        :user_id,
        :user_pending
      ]
    end
  end

  attributes do
    attribute :group_id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
      default 0
    end

    attribute :user_id, :integer do
      public? true
      default 0
      allow_nil? false
    end

    attribute :user_pending, :integer do
      public? true
      constraints min: -32768, max: 32767
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
        source_attribute :user_id
        attribute_type :integer
      end
    end
  end

  identities do
    identity :group_id_phpbb_user_group_index, [:group_id]
    identity :user_id_phpbb_user_group_index, [:user_id]
  end
end
