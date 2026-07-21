defmodule Samba.Util.FaqImporter do
  alias Phpbb.FaqItem

  @doc """
  Parses a legacy PHP file containing multiple variable blocks (e.g. $faq[], $forum[])
  and imports them into Ash with their respective section groupings.
  """
  def import_from_php_string(php_content) do
    # General regex to match ANY array variable assignment: $variable_name[] = array("...", "...");
    regex = ~r/\$([a-zA-Z0-9_]+)\[\]\s*=\s*array\s*\("(.*?)",\s*"(.*?)"\);/s

    results =
      php_content
    |> String.split("\n")
       |> Enum.with_index(1)
       |> Enum.reduce({[], "General", "faq"}, fn {line, index}, {acc, current_section, current_var} ->
      case Regex.run(regex, String.trim(line)) do
        [_, var_name, "--", heading] ->
          # A block heading marker denotes a new section for this variable stream
          {acc, heading, var_name}

        [_, var_name, question, answer] ->
          clean_question = String.replace(question, ~r/\\(.)/, "\\1")
          clean_answer = String.replace(answer, ~r/\\(.)/, "\\1")

          item_data = %{
            variable: var_name,
            section: current_section,
            question: clean_question,
            answer: clean_answer,
            position: index
          }

          {[item_data | acc], current_section, var_name}

        _ ->
          {acc, current_section, current_var}
      end
    end)

    case results do
      {items, _, _} when items != [] ->
        # Perform bulk or sequential imports via Ash
        Enum.each(Enum.reverse(items), fn item ->
          FaqItem.import_item!(item)
        end)

        {:ok, length(items)}

      _ ->
        {:ok, 0}
    end
  end
end