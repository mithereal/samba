defmodule PhpBB.Confirm do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_confirm"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :confirm_id,
        :session_id,
        :code
      ]
    end
  end

  attributes do
    attribute :confirm_id, :string do
      generated? true
      primary_key? true
      allow_nil? false
      default ""
    end

    attribute :session_id, :integer do
      allow_nil? false
      primary_key? true
      default ""
    end

    relationships do
      belongs_to :session, PhpBB.Sessions do
        destination_attribute :session_id
        source_attribute :session_id
        attribute_type :integer
      end
    end

    attribute :code, :string do
      allow_nil? true
      public? true
    end
  end
end
