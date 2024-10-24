defmodule GdCollabManageCollabTools.PartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GdCollabManageCollabTools.Parts` context.
  """

  @doc """
  Generate a collab_part.
  """
  def collab_part_fixture(attrs \\ %{}) do
    {:ok, collab_part} =
      attrs
      |> Enum.into(%{
        comments: "some comments",
        end_time: 42,
        label: "some label",
        start_time: 42,
        status: "some status",
        to_do_item_id: 42
      })
      |> GdCollabManageCollabTools.Parts.create_collab_part()

    collab_part
  end
end
