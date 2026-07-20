defmodule PhpBB.PrivmsgsText do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_privmsgs_text"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:phpbb_privmsgs_text]
    defaults [:create, :read, :update, :destroy]
  end
  attributes do
    primary_key(:phpbb_privmsgs_text)

    attribute :privmsgs_bbcode_uid, :integer do
      allow_nil? true
      public? true
    end

    attribute :privmsgs_text, :string do
      allow_nil? true
      public? true
    end
  end
end
