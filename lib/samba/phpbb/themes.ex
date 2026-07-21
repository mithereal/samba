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
    default_accept [:themes_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    attribute :themes_id, :integer do
      writable? false
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
