defmodule PhpBB.SearchResults do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_search_results"
    repo Samba.Repo
  end

  actions do
    default_accept [:search_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :search_id, :integer do
      writable? false
      generated? true
      primary_key?(true)
      allow_nil? false
    end

    relationships do
      belongs_to :session, PhpBB.Sessions do
        destination_attribute :session_id
      end
    end

    attribute :search_time, :integer do
      allow_nil? true
      public? true
    end

    attribute :search_array, :integer do
      allow_nil? true
      public? true
    end
  end
end
