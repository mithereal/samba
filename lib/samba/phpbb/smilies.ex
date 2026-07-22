defmodule PhpBB.Smiles do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_smilies"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :smilies_id,
        :code,
        :smile_url,
        :emoticon
      ]
    end
  end

  attributes do
    attribute :smilies_id, :integer do
      writable? true
      generated? true
      primary_key? true
      allow_nil? false
    end

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
