defmodule Samba.Generators.Fact do
  import Ash.Generator
  alias Samba.Core.Fact

  def fact(opts \\ []) do
    changeset_generator(
      Fact,
      :create,
      defaults: [
        fact: sequence(:fact, &"fact_#{&1}")
      ],
      overrides: opts,
      authorize?: false
    )
  end
end
