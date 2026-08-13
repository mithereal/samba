defmodule Samba.Accounts.ObanActorPersister do
  use AshOban.ActorPersister

  @impl true
  def store(%Samba.Accounts.User{id: id}), do: %{"type" => "user", "id" => id}

  @impl true
  def lookup(%{"type" => "user", "id" => id}) do
    Samba.Accounts.User.get_by_id(id, authorize?: false)
  end

  def lookup(nil), do: {:ok, nil}
end
