defmodule PhpBB.Confirm do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_confirm"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:confirm_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:confirm_id)

    attribute :session_id, :integer do
      allow_nil? true
      public? true
    end

    attribute :code, :string do
      allow_nil? true
      public? true
    end
  end

  index ["session_id", "confirm_id"], unique: true
end
