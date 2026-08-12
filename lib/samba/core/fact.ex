defmodule Samba.Core.Fact do
  use Ash.Resource,
    domain: Elixir.Samba.Core,
    data_layer: AshPostgres.DataLayer,
    extensions: [],
    authorizers: []

  postgres do
    table "facts"
    repo Samba.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:fact]
    end

    update :update do
      accept [:fact]
    end
  end

  attributes do
    attribute :id, :integer do
      public? true
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :fact, :string do
      allow_nil? false
    end

    timestamps()
  end
end
