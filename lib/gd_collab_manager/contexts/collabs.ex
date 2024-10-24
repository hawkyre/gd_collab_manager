defmodule GdCollabManager.Collabs do
  @moduledoc """
  The collabs context.
  """

  import Ecto.Query, warn: false
  alias GdCollabManager.Repo

  alias GdCollabManager.Collabs.Collab

  @doc """
  Returns the list of collabs for the given user.

  ## Examples

      iex> list_user_collabs(user)
      [%GdCollabManager.Collabs.Collab{}, ...]
  """
  @spec get_user_collabs(GdCollabManager.Accounts.User.t()) :: [Collab.Info.t()]
  def get_user_collabs(user) do
    Repo.all(
      from c in Collab.Info,
        join: cp in assoc(c, :collab_participants),
        where: cp.user_id == ^user.id
    )
    |> Repo.preload(collab_participants: [:user])
  end

  @spec get_user_collabs(GdCollabManager.Accounts.User.t()) :: Collab.t() | nil
  def get_collab(user, collab_id) do
    Repo.all(
      from c in Collab,
        join: cp in assoc(c, :collab_participants),
        where: cp.user_id == ^user.id and c.id == ^collab_id
    )
    |> Repo.preload([
      :tags,
      to_do_items: [:tags, :responsibles],
      collab_participants: [:user],
      parts: [to_do_item: [:tags, :responsibles]]
    ])
    |> List.first()
  end

  @doc """
  Creates a collab given a name, description, and list of user IDs. The creator will be marked as the host.
  """
  @spec create_collab(any(), map()) :: any()
  def create_collab(host_id, attrs \\ %{}) do
    participants_assoc =
      [%{role: "host", user_id: host_id}] ++
        (attrs |> Map.get("users", []) |> Enum.map(&%{role: "member", user_id: &1}))

    attrs = Map.put(attrs, "collab_participants", participants_assoc)

    Collab.new()
    |> Collab.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Generates a topic for a collab (primarily used for pubsub).
  """
  @spec generate_collab_topic(Collab.t()) :: String.t()
  def generate_collab_topic(collab) do
    "collab:#{collab.id}"
  end
end
