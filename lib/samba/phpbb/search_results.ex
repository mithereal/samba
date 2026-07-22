defmodule PhpBB.SearchResults do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_search_results"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :search_id,
        :session_id,
        :search_time,
        :search_array
      ]
    end
  end

  attributes do
    attribute :search_id, :integer do
      default 0
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :session_id, :integer do
      default 0
      allow_nil? false
    end

    relationships do
      belongs_to :session, PhpBB.Sessions do
        destination_attribute :session_id
        source_attribute :session_id
        attribute_type :integer
      end
    end

    attribute :search_time, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :search_array, :integer do
      allow_nil? false
      public? true
    end
  end

  identities do
    identity :unique_name, [:session_id]
  end
end
