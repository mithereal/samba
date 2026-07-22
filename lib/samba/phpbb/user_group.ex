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
    default_accept [:group_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :group_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
      default 0
    end

    attribute :user_id, :integer do
      default 0
      allow_nil? false
    end

    attribute :user_pending, :integer do
      constraints min: -32768, max: 32767
      allow_nil? false
    end

    relationships do
      belongs_to :user, PhpBB.Users do
        destination_attribute :user_id
        attribute_type :integer
      end
    end
  end

  identities do
    identity :unique_name, [:group_id, :user_id]
    identity :unique_name, [:user_id]
  end
end
