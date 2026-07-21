defmodule PhpBB.PrivmsgsText do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_privmsgs_text"
    repo Samba.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    relationships do
      belongs_to :privmsgs, PhpBB.Privmsgs do
        destination_attribute :phpbb_privmsgs_text
      end
    end

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
