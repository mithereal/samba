defmodule Samba.Ledger.Account do
  use Ash.Resource,
    domain: Elixir.Samba.Ledger,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshDoubleEntry.Account],
    authorizers: [Ash.Policy.Authorizer]

  account do
    # configure the other resources it will interact with
    transfer_resource Samba.Ledger.Transfer
    balance_resource Samba.Ledger.Balance
  end

  account do
    transfer_resource Samba.Ledger.Transfer
    balance_resource Samba.Ledger.Balance
  end

  postgres do
    table "ledger_accounts"
    repo Samba.Repo
  end

  actions do
    defaults [:read]

    create :open do
      accept [:identifier, :currency, :nature, :name]
    end

    read :lock_accounts do
      # Used to lock accounts while doing ledger operations
      prepare {AshDoubleEntry.Account.Preparations.LockForUpdate, []}
    end
  end

  policies do
    policy always() do
      access_type :strict
      authorize_if Samba.Accounts.Checks.Authorize
    end
  end

  preparations do
    prepare Samba.Preparations.SetTenant
  end

  changes do
    change Samba.Changes.SetTenant
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :identifier, :string do
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
    end

    attribute :currency, :string do
      allow_nil? false
    end

    attribute :nature, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :balances, Samba.Ledger.Balance do
      destination_attribute :account_id
    end
  end

  calculations do
    calculate :balance_as_of_ulid, :money do
      calculation {AshDoubleEntry.Account.Calculations.BalanceAsOfUlid, resource: __MODULE__}

      argument :ulid, AshDoubleEntry.ULID do
        allow_nil? false
        allow_expr? true
      end
    end

    calculate :balance_as_of, :money do
      calculation {AshDoubleEntry.Account.Calculations.BalanceAsOf, resource: __MODULE__}

      argument :timestamp, :utc_datetime_usec do
        allow_nil? false
        allow_expr? true
        default &DateTime.utc_now/0
      end
    end
  end

  identities do
    identity :unique_identifier, [:identifier]
  end
end
