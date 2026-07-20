defmodule PhpBB.ThemesName do
  use Ash.Resource,
    domain: PhpBB,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_themes_name"
    repo PhpBB.Repo
  end

  actions do
    default_accept [:themes_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    primary_key(:themes_id)

    attribute :tr_color1, :string do
      allow_nil? true
      public? true
    end

    attribute :tr_color2, :string do
      allow_nil? true
      public? true
    end

    attribute :tr_color3, :string do
      allow_nil? true
      public? true
    end

    attribute :tr_class1, :string do
      allow_nil? true
      public? true
    end

    attribute :tr_class2, :string do
      allow_nil? true
      public? true
    end

    attribute :tr_class3, :string do
      allow_nil? true
      public? true
    end

    attribute :td_color1, :string do
      allow_nil? true
      public? true
    end

    attribute :td_color2, :string do
      allow_nil? true
      public? true
    end

    attribute :td_color3, :string do
      allow_nil? true
      public? true
    end

    attribute :fontface1, :string do
      allow_nil? true
      public? true
    end

    attribute :fontface2, :string do
      allow_nil? true
      public? true
    end

    attribute :fontface3, :string do
      allow_nil? true
      public? true
    end

    attribute :fontsize1, :string do
      allow_nil? true
      public? true
    end

    attribute :fontsize2, :string do
      allow_nil? true
      public? true
    end

    attribute :fontsize3, :string do
      allow_nil? true
      public? true
    end

    attribute :fontcolor1, :string do
      allow_nil? true
      public? true
    end

    attribute :fontcolor2, :string do
      allow_nil? true
      public? true
    end

    attribute :fontcolor3, :string do
      allow_nil? true
      public? true
    end

    attribute :span_class1, :string do
      allow_nil? true
      public? true
    end

    attribute :span_class2, :string do
      allow_nil? true
      public? true
    end

    attribute :span_class3, :string do
      allow_nil? true
      public? true
    end
  end
end
