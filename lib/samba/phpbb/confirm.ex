defmodule PhpBB.Confirm do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_confirm"
    repo Samba.Repo
  end

  actions do
    default_accept [:confirm_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :confirm_id, :integer do
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

    attribute :code, :string do
      allow_nil? true
      public? true
    end
  end
end
