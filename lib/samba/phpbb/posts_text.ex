defmodule PhpBB.PostsText do
  use Ash.Resource,
      domain: PhpBB.Domain,
      data_layer: AshPostgres.DataLayer,
      notifiers: Ash.Notifier.PubSub,
      primary_read_warning?: false

  postgres do
    table "phpbb_posts_text"
    repo Samba.Repo
  end

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true
      prepare &PhpBB.PostsText.deserialize_on_read/2
    end

    create :create do
      primary? true

      accept [
        :post_id,
        :post_subject,
        :post_text
      ]

      change &__MODULE__.process_html_to_bbcode/2
    end
  end

  attributes do
    attribute :post_id, :integer do
      public? true
      primary_key? true
      allow_nil? false
    end

    attribute :bbcode_uid, :string do
      public? true
      default " "
      allow_nil? true
    end

    attribute :post_subject, :string do
      public? true
      default " "
      allow_nil? true
    end

    # Stores the uid-infused BBCode string in the DB, but transforms to HTML on read
    attribute :post_text, :string do
      public? true
      allow_nil? true
    end

    # Virtual attribute to expose the raw clean BBCode string if ever needed directly
    attribute :clean_bbcode, :string do
      public? true
      writable? false
      allow_nil? true
      generated? true
    end

    # Virtual attribute to expose the parsed AST structure on read
    attribute :ast, :map do
      public? true
      writable? false
      allow_nil? true
      generated? true
    end
  end

  relationships do
    belongs_to :post, PhpBB.Posts do
      destination_attribute :post_id
      source_attribute :post_id
      attribute_type :integer
    end
  end

  # --- Create Action Pipeline ---

  def process_html_to_bbcode(changeset, _context) do
    case Ash.Changeset.get_argument_or_attribute(changeset, :post_text) do
      nil ->
        changeset

      html ->
        uid = generate_bbcode_uid()

        case BBCode.HtmlToBbcode.convert(html) do
          {:ok, base_bbcode} ->
            uid_infused_bbcode = inject_bbcode_uid(base_bbcode, uid)

            changeset
            |> Ash.Changeset.force_change_attribute(:bbcode_uid, uid)
            |> Ash.Changeset.force_change_attribute(:post_text, uid_infused_bbcode)

          {:error, reason} ->
            Ash.Changeset.add_error(changeset, field: :post_text, message: "failed to transform HTML to BBCode: #{inspect(reason)}")
        end
    end
  end

  # --- Read Action Deserialization (Transforms to HTML) ---

  def deserialize_on_read(query, _context) do
    Ash.Query.after_action(query, fn _query, results ->
      deserialized_results = Enum.map(results, fn record ->
        case record.post_text do
          nil ->
            record
          text ->
            # 1. Strip the phpBB uid from tags
            clean_bbcode = strip_bbcode_uid(text, record.bbcode_uid)

            # 2. Parse the clean BBCode string into an AST
            {ast, html_output} = case BBCode.Parser.parse(clean_bbcode) do
              {:ok, parsed_ast} ->
                # 3. Generate HTML from the AST using your generator
                case BBCode.Generator.to_html(parsed_ast) do
                  {:ok, html} -> {parsed_ast, html}
                  {:error, _} -> {parsed_ast, ""}
                end
              {:error, _} ->
                {[], ""}
            end

            # 4. Return record with post_text replaced by plain HTML, plus preserved metadata
            %{record | post_text: html_output}
        end
      end)

      {:ok, deserialized_results}
    end)
  end

  # --- Helpers ---

  defp generate_bbcode_uid do
    :crypto.strong_rand_bytes(4)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 8)
  end

  defp inject_bbcode_uid(bbcode_string, uid) do
    bbcode_string
    |> Regex.replace(~r/\[([a-z0-9\*]+)(=[^\]]+)?\]/ui, "[\\1\\2:#{uid}]")
    |> Regex.replace(~r/\[\/([a-z0-9\*]+)\]/ui, "[/\\1:#{uid}]")
  end

  defp strip_bbcode_uid(bbcode_string, nil), do: bbcode_string
  defp strip_bbcode_uid(bbcode_string, ""), do: bbcode_string
  defp strip_bbcode_uid(bbcode_string, uid) do
    escaped_uid = Regex.escape(String.trim(uid))

    bbcode_string
    |> Regex.replace(~r/:#{escaped_uid}\b/ui, "")
  end
end