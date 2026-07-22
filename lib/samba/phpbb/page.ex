defmodule PhpBB.Page do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_pages"
    repo Samba.Repo
  end

  code_interface do
    define :by_name, action: :read, get_by: [:name]
  end

  actions do
    defaults [:create, :update, :destroy]

    read :read do
      primary? true
    end

    read :by_name do
      argument :name, :string, allow_nil?: false
      get? true

      filter expr(name == ^arg(:name))
    end
  end

  attributes do
    attribute :page_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :body, :string do
      allow_nil? true
      public? true
    end
  end
end
