defmodule GdCollabManageCollabTools.PartsTest do
  use GdCollabManager.DataCase

  alias GdCollabManageCollabTools.Parts

  describe "collab_parts" do
    alias GdCollabManager.CollabTools.Parts.CollabPart

    import GdCollabManageCollabTools.PartsFixtures

    @invalid_attrs %{
      label: nil,
      status: nil,
      comments: nil,
      start_time: nil,
      end_time: nil,
      to_do_item_id: nil
    }

    test "list_collab_parts/0 returns all collab_parts" do
      collab_part = collab_part_fixture()
      assert Parts.list_collab_parts() == [collab_part]
    end

    test "get_collab_part!/1 returns the collab_part with given id" do
      collab_part = collab_part_fixture()
      assert Parts.get_collab_part!(collab_part.id) == collab_part
    end

    test "create_collab_part/1 with valid data creates a collab_part" do
      valid_attrs = %{
        label: "some label",
        status: "some status",
        comments: "some comments",
        start_time: 42,
        end_time: 42,
        to_do_item_id: 42
      }

      assert {:ok, %CollabPart{} = collab_part} = Parts.create_collab_part(valid_attrs)
      assert collab_part.label == "some label"
      assert collab_part.status == "some status"
      assert collab_part.comments == "some comments"
      assert collab_part.start_time == 42
      assert collab_part.end_time == 42
      assert collab_part.to_do_item_id == 42
    end

    test "create_collab_part/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Parts.create_collab_part(@invalid_attrs)
    end

    test "update_collab_part/2 with valid data updates the collab_part" do
      collab_part = collab_part_fixture()

      update_attrs = %{
        label: "some updated label",
        status: "some updated status",
        comments: "some updated comments",
        start_time: 43,
        end_time: 43,
        to_do_item_id: 43
      }

      assert {:ok, %CollabPart{} = collab_part} =
               Parts.update_collab_part(collab_part, update_attrs)

      assert collab_part.label == "some updated label"
      assert collab_part.status == "some updated status"
      assert collab_part.comments == "some updated comments"
      assert collab_part.start_time == 43
      assert collab_part.end_time == 43
      assert collab_part.to_do_item_id == 43
    end

    test "update_collab_part/2 with invalid data returns error changeset" do
      collab_part = collab_part_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Parts.update_collab_part(collab_part, @invalid_attrs)

      assert collab_part == Parts.get_collab_part!(collab_part.id)
    end

    test "delete_collab_part/1 deletes the collab_part" do
      collab_part = collab_part_fixture()
      assert {:ok, %CollabPart{}} = Parts.delete_collab_part(collab_part)
      assert_raise Ecto.NoResultsError, fn -> Parts.get_collab_part!(collab_part.id) end
    end

    test "change_collab_part/1 returns a collab_part changeset" do
      collab_part = collab_part_fixture()
      assert %Ecto.Changeset{} = Parts.change_collab_part(collab_part)
    end
  end
end
