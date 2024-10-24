defmodule GdCollabManager.CollabsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GdCollabManager.Collabs` context.
  """
  alias GdCollabManager.Repo

  def unique_collab_name, do: "collab#{System.unique_integer()}"

  def valid_collab_description,
    do: "this is the collab's description, just a generic one"

  def valid_collab_attributes(attrs \\ %{})

  def valid_collab_attributes(%{host_id: host_id} = attrs) when is_integer(host_id) do
    Enum.into(attrs, %{
      "name" => unique_collab_name(),
      "description" => valid_collab_description(),
      "host_id" => host_id
    })
  end

  def valid_collab_attributes(attrs) do
    host_id = GdCollabManager.AccountsFixtures.user_fixture().id

    Enum.into(attrs, %{
      "name" => unique_collab_name(),
      "description" => valid_collab_description(),
      "host_id" => host_id
    })
  end

  @spec collab_fixture() :: nil | [%{optional(atom()) => any()}] | %{optional(atom()) => any()}
  def collab_fixture(attrs \\ %{}) do
    attrs = valid_collab_attributes(attrs)

    {:ok, collab} =
      GdCollabManager.Collabs.create_collab(attrs["host_id"], attrs)

    collab |> Repo.preload([:tags, :to_do_items, collab_participants: [:user]])
  end

  def user_with_collab_fixture(attrs \\ %{}) do
    user = GdCollabManager.AccountsFixtures.user_fixture()
    attrs = valid_collab_attributes(attrs)

    {:ok, collab} =
      GdCollabManager.Collabs.create_collab(user.id, attrs)

    collab |> Repo.preload([:participants, :tags, :to_do_items])
  end

  def create_collab_members(count) do
    Enum.map(1..count, fn _ ->
      GdCollabManager.AccountsFixtures.user_fixture().id
    end)
  end
end
