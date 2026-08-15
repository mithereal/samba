defmodule Samba.Core.Fact do
  use Ash.Resource,
    otp_app: :samba,
    domain: Elixir.Samba.Core,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban],
    authorizers: []

  postgres do
    table "facts"
    repo Samba.Repo
  end

  code_interface do
    define :random, action: :random
  end

  actions do
    defaults [:read]

    create :create do
      accept [:fact]
    end

    read :random do
      prepare fn query, _ ->
        require Ash.Sort
        Ash.Query.sort(query, Ash.Sort.expr_sort(fragment("RANDOM()")))
      end
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
