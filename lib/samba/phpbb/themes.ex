defmodule PhpBB.Themes do
  use Ash.Resource,
    domain: Elixir.PhpBB.Domain,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "phpbb_themes"
    repo Samba.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [
        :themes_id,
        :style_name,
        :template_name,
        :head_stylesheet,
        :body_bgcolor,
        :body_text,
        :body_link,
        :body_vlink,
        :body_alink,
        :body_hlink,
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
        :span_class3,
        :img_size_poll,
        :img_size_privmsg
      ]
    end
  end

  attributes do
    attribute :themes_id, :integer do
      generated? true
      primary_key? true
      allow_nil? false
    end

    attribute :style_name, :string do
      allow_nil? true
      public? true
    end

    attribute :template_name, :string do
      allow_nil? true
      public? true
    end

    attribute :head_stylesheet, :string do
      allow_nil? true
      public? true
    end

    attribute :body_bgcolor, :string do
      allow_nil? true
      public? true
    end

    attribute :body_text, :string do
      allow_nil? true
      public? true
    end

    attribute :body_link, :string do
      allow_nil? true
      public? true
    end

    attribute :body_vlink, :string do
      allow_nil? true
      public? true
    end

    attribute :body_alink, :string do
      allow_nil? true
      public? true
    end

    attribute :body_hlink, :string do
      allow_nil? true
      public? true
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

    attribute :img_size_poll, :string do
      allow_nil? true
      public? true
    end

    attribute :img_size_privmsg, :string do
      allow_nil? true
      public? true
    end
  end
end
