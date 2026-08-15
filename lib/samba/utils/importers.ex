defmodule Samba.Utils.Importers do
  @doc """
  Imports from a CSV file path into the resource.
  """
  def import_facts(file_path \\ "priv/data/facts.csv") do
    file_path
    |> File.stream!()
    |> Samba.CSVParser.parse_stream(skip_headers: false)
    # Drop header row if your CSV includes headers
    |> Stream.drop(1)
    |> Stream.each(fn row ->
      # Adjust the index depending on which column contains the fact text.
      # For example, if it's the first column:
      fact_text = List.last(row)

      attrs = %{
        fact: fact_text
      }

      case Samba.Core.Fact |> Ash.Changeset.for_create(:create, attrs) |> Ash.create() do
        {:ok, _fact} ->
          :ok

        {:error, error} ->
          IO.inspect(error, label: "Failed to import fact")
      end
    end)
    |> Stream.run()
  end
end
