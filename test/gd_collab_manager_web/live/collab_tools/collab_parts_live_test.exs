defmodule GdCollabManagerWeb.CollabTools.CollabPartsLiveTest do
  use GdCollabManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import GdCollabManageCollabTools.PartsFixtures

  @create_attrs %{
    label: "some label",
    status: "some status",
    comments: "some comments",
    start_time: 42,
    end_time: 42,
    to_do_item_id: 42
  }
  @update_attrs %{
    label: "some updated label",
    status: "some updated status",
    comments: "some updated comments",
    start_time: 43,
    end_time: 43,
    to_do_item_id: 43
  }
  @invalid_attrs %{
    label: nil,
    status: nil,
    comments: nil,
    start_time: nil,
    end_time: nil,
    to_do_item_id: nil
  }

  defp create_collab_part(_) do
    collab_part = collab_part_fixture()
    %{collab_part: collab_part}
  end

  describe "Index" do
    setup [:create_collab_part]

    test "lists all collab_parts", %{conn: conn, collab_part: collab_part} do
      {:ok, _index_live, html} = live(conn, ~p"/collab_tools/collab_parts")

      assert html =~ "Listing Collab parts"
      assert html =~ collab_part.label
    end

    test "saves new collab_part", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/collab_tools/collab_parts")

      assert index_live |> element("a", "New Collab part") |> render_click() =~
               "New Collab part"

      assert_patch(index_live, ~p"/collab_tools/collab_parts/new")

      assert index_live
             |> form("#collab_part-form", collab_part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#collab_part-form", collab_part: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/collab_tools/collab_parts")

      html = render(index_live)
      assert html =~ "Collab part created successfully"
      assert html =~ "some label"
    end

    test "updates collab_part in listing", %{conn: conn, collab_part: collab_part} do
      {:ok, index_live, _html} = live(conn, ~p"/collab_tools/collab_parts")

      assert index_live |> element("#collab_parts-#{collab_part.id} a", "Edit") |> render_click() =~
               "Edit Collab part"

      assert_patch(index_live, ~p"/collab_tools/collab_parts/#{collab_part}/edit")

      assert index_live
             |> form("#collab_part-form", collab_part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#collab_part-form", collab_part: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/collab_tools/collab_parts")

      html = render(index_live)
      assert html =~ "Collab part updated successfully"
      assert html =~ "some updated label"
    end

    test "deletes collab_part in listing", %{conn: conn, collab_part: collab_part} do
      {:ok, index_live, _html} = live(conn, ~p"/collab_tools/collab_parts")

      assert index_live
             |> element("#collab_parts-#{collab_part.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#collab_parts-#{collab_part.id}")
    end
  end
end
