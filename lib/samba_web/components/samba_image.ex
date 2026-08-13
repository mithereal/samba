defmodule Samba.Components.Samba.Image do
  use Phoenix.Component

  attr :src, :string, required: true
  attr :image_mode, :atom, default: :local, doc: "Passed down from LiveView assigns or DB"
  attr :width, :integer, default: nil
  attr :height, :integer, default: nil
  attr :fit, :atom, default: :cover
  attr :format, :atom, default: :webp
  attr :quality, :integer, default: 80
  attr :alt, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  def render(assigns) do
    assigns = assign(assigns, :src_url, build_image_url(assigns.image_mode, assigns))

    ~H"""
    <img src={@src_url} alt={@alt} class={@class} width={@width} height={@height} {@rest} />
    """
  end

  # --- LOCAL MODE (phx_image / local processing) ---
  defp build_image_url(:local, assigns) do
    query =
      [
        width: assigns.width,
        height: assigns.height,
        fit: assigns.fit,
        format: assigns.format,
        quality: assigns.quality
      ]
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> URI.encode_query()

    if query == "" do
      assigns.src
    else
      "/images/optimize?path=#{URI.encode_www_form(assigns.src)}&#{query}"
    end
  end

  # --- CLOUD CDN MODE (image_components / IR pipeline) ---
  defp build_image_url(:cdn, assigns) do
    host = System.get_env("CDN_HOST") || "https://imagedelivery.net/your-account-hash"
    # Can also be fetched from DB if multi-CDN is needed
    provider = :cloudflare

    alias Image.Components.URL
    alias Image.Plug.Pipeline
    alias Image.Plug.Pipeline.Ops

    pipeline = %Pipeline{
      ops:
        [
          assigns.width &&
            %Ops.Resize{width: assigns.width, height: assigns.height, fit: assigns.fit}
        ]
        |> Enum.reject(&is_nil/1),
      output: %Ops.Format{type: assigns.format, quality: assigns.quality}
    }

    apply(URL, provider, [pipeline, [source_path: assigns.src, host: host]])
  end
end
