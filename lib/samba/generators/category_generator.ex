defmodule Samba.Generators.CategoryGenerator do
  @moduledoc """
  Generates default phpBB-style categories using the PhpBB.Categories Ash resource.
  """

  def default_categories do
    [
      %{cat_title: "General Discussion", cat_order: 10},
      %{cat_title: "Technical Support & Projects", cat_order: 20},
      %{cat_title: "Classifieds", cat_order: 30},
      %{cat_title: "Community & Gallery", cat_order: 40}
    ]
  end

  def seed_categories do
    IO.puts("Starting category seeding...")

    for attrs <- default_categories() do
      case create_category(attrs) do
        {:ok, category} ->
          IO.puts("Successfully created category: #{category.cat_title} (ID: #{category.cat_id})")

        {:error, error} ->
          IO.puts("Failed to create category #{attrs.cat_title}: #{inspect(error)}")
      end
    end

    IO.puts("Category seeding complete!")
  end

  defp create_category(attrs) do
    PhpBB.Categories
    |> Ash.Changeset.for_create(:create, attrs)
    |> Ash.create(domain: PhpBB.Domain)
  end
end
