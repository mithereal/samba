defmodule Samba.Accounts.Fragments.Multitenancies do
  use Spark.Dsl.Fragment, of: Ash.Resource

  preparations do
    prepare Samba.Preparations.SetTenant
  end

  changes do
    change Samba.Changes.SetTenant
  end

  multitenancy do
    strategy :context
  end
end
