defmodule GdCollabManager.CollabsTest do
  use GdCollabManager.DataCase
  alias GdCollabManager.Collabs

  import GdCollabManager.CollabsFixtures

  describe "create_collab/1" do
    test "creates a collab without members" do
      collab = collab_fixture()
      assert length(collab.collab_participants) == 1
    end

    test "creates a collab with members" do
      host = GdCollabManager.AccountsFixtures.user_fixture()
      members = create_collab_members(3)

      collab =
        members
        |> then(&valid_collab_attributes(%{"users" => &1, "host_id" => host.id}))
        |> collab_fixture()

      assert length(collab.collab_participants) == 4

      assert collab.collab_participants
             |> Enum.find(&(&1.role == "host"))
             |> then(&(&1.user.id == host.id))

      assert collab.collab_participants
             |> Enum.filter(&(&1.role == "member"))
             |> Enum.map(& &1.user.id)
             |> Enum.sort() == Enum.sort(members)
    end

    test "validates required fields" do
      attrs = valid_collab_attributes(%{"name" => nil})
      assert {:error, changeset} = Collabs.create_collab(attrs)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "validates maximum length of name" do
      %{"host_id" => hid} =
        attrs = valid_collab_attributes(%{"name" => String.duplicate("a", 101)})

      assert {:error, changeset} = Collabs.create_collab(hid, attrs)
      assert "should be at most 100 character(s)" in errors_on(changeset).name
    end

    test "validates maximum length of description" do
      %{"host_id" => hid} =
        attrs = valid_collab_attributes(%{"description" => String.duplicate("a", 301)})

      assert {:error, changeset} = Collabs.create_collab(hid, attrs)
      assert "should be at most 300 character(s)" in errors_on(changeset).description
    end
  end

  describe "get_user_collabs/1" do
    test "returns preloaded collabs" do
      user = GdCollabManager.AccountsFixtures.user_fixture()
      collab_fixture(%{"host_id" => user.id})

      user_collabs = GdCollabManager.Collabs.get_user_collabs(user)

      assert Enum.count(user_collabs) == 1

      first_collab = user_collabs |> Enum.at(0)
      assert first_collab.collab_participants |> Enum.count() == 1
      assert first_collab.collab_participants |> Enum.at(0) |> then(& &1.user.id) == user.id
    end

    test "returns all user collabs (user is only host)" do
      user = GdCollabManager.AccountsFixtures.user_fixture()

      1..3
      |> Enum.each(fn _ ->
        collab_fixture(%{"host_id" => user.id})
      end)

      user_collabs = GdCollabManager.Collabs.get_user_collabs(user)

      assert Enum.count(user_collabs) == 3
    end

    test "returns all user collabs (user is not host)" do
      user = GdCollabManager.AccountsFixtures.user_fixture()
      host = GdCollabManager.AccountsFixtures.user_fixture()

      assert Enum.count(GdCollabManager.Collabs.get_user_collabs(user)) == 0

      1..3
      |> Enum.each(fn _ ->
        collab_fixture(%{"host_id" => host.id, "users" => [user.id]})
      end)

      assert Enum.count(GdCollabManager.Collabs.get_user_collabs(user)) == 3
      assert Enum.count(GdCollabManager.Collabs.get_user_collabs(host)) == 3
    end
  end

  describe "get_collab/2" do
    test "returns preloaded collab" do
      user = GdCollabManager.AccountsFixtures.user_fixture()
      collab = collab_fixture(%{"host_id" => user.id})

      collab = GdCollabManager.Collabs.get_collab(user, collab.id)

      assert collab.tags == []
      assert collab.to_do_items == []
      assert collab.collab_participants |> Enum.count() == 1
      assert collab.collab_participants |> Enum.at(0) |> then(& &1.user.id) == user.id
    end

    test "returns nil if collab does not exist" do
      user = GdCollabManager.AccountsFixtures.user_fixture()
      assert GdCollabManager.Collabs.get_collab(user, 1) == nil
    end
  end
end
