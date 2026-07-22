defmodule PhpBB.ThemesName do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_themes_name"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [
        :themes_id,
        :tr_color1,
        :tr_color2,
        :tr_color3,
        :tr_class1,
        :tr_class2,
        :tr_class3,
        :td_color1,
        :td_color2,
        :td_color3,
        :fontface1,
        :fontface2,
        :fontface3,
        :fontsize1,
        :fontsize2,
        :fontsize3,
        :fontcolor1,
        :fontcolor2,
        :fontcolor3,
        :span_class1,
        :span_class2,
        :span_class3
      ]
    end
  end

  attributes do
    relationships do
      belongs_to :theme, PhpBB.Themes do
        destination_attribute :themes_id
      end
    end

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
