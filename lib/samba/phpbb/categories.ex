defmodule PhpBB.Categories do
  use Ash.Resource,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "phpbb_categories"
    repo PhpBB.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:cat_title, :cat_order]
    end

    update :update do
      # Make sure :cat_order is included here!
      accept [:cat_title, :cat_order]
    end
  end

  attributes do
    integer_primary_key :cat_id, source: :cat_id
    attribute :cat_title, :string, allow_nil?: false
    attribute :cat_order, :integer, allow_nil?: false
  end
end