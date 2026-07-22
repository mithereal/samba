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
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :privmsgs_text_id,
        :privmsgs_bbcode_uid,
        :privmsgs_text
      ]
    end
  end

  attributes do
    relationships do
      belongs_to :privmsgs, PhpBB.Privmsgs do
        source_attribute :privmsgs_text_id
        destination_attribute :privmsgs_id
        attribute_type :integer
      end
    end

    attribute :privmsgs_text_id, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :privmsgs_bbcode_uid, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :privmsgs_text, :string do
      allow_nil? false
      public? true
    end
  end
end
