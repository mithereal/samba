defmodule PhpBB.FaqItem do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_faq_items"
    repo Samba.Repo
  end

  code_interface do
    define :read_all, action: :read
    define :import_item, action: :import_item
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    create :import_item do
      accept [:variable, :section, :question, :answer, :position]
    end

    attributes do
      attribute :id, :integer do
        generated? true
        primary_key? true
        allow_nil? false
      end

      # Tracks whether it came from $faq[], $forum[], etc.
      attribute :variable, :string, allow_nil?: false
      attribute :section, :string, allow_nil?: false
      attribute :question, :string, allow_nil?: false
      attribute :answer, :string, allow_nil?: true
      attribute :position, :integer, allow_nil?: false
    end
  end
end
