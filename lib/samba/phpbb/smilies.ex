defmodule PhpBB.Smiles do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_smilies"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:smilies_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key(:smilies_id)

    attribute :code, :string do
      allow_nil? true
      public? true
    end

    attribute :smile_url, :string do
      allow_nil? true
      public? true
    end

    attribute :emoticon, :string do
      allow_nil? true
      public? true
    end
  end
end
