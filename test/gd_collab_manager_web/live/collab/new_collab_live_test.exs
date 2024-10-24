defmodule GdCollabManagerWeb.NewCollabLiveTest do
  alias GdCollabManager.Repo
  use GdCollabManagerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import GdCollabManager.AccountsFixtures
  import GdCollabManager.CollabsFixtures

  describe "New collab page" do
    setup %{conn: conn} do
      user = user_fixture()
      %{conn: log_in_user(conn, user), user: user}
    end

    test "renders /my-collabs/new page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/my-collabs/new")

      assert html =~ "Create new collab"
      assert html =~ "Name"
      assert html =~ "Description"
      assert html =~ "Users"
    end
  end

  describe "create a collab" do
    setup %{conn: conn} do
      user = user_fixture()
      %{conn: log_in_user(conn, user), user: user}
    end

    test "creates a collab with a name and description", %{conn: conn, user: user} do
      collab_name = unique_collab_name()

      assert GdCollabManager.Collabs.get_user_collabs(user) == []

      {:ok, lv, _html} = live(conn, ~p"/my-collabs/new")

      {:error, {:live_redirect, %{to: redirect_to}}} =
        form =
        form(lv, "#new-collab-form", %{
          "name" => collab_name,
          "description" => "test description"
        })
        |> render_submit()

      {:ok, _lv, html} = form |> follow_redirect(conn, redirect_to)

      assert html =~ collab_name

      IO.inspect(user)
      IO.inspect(GdCollabManager.Collabs.get_user_collabs(user))
      IO.inspect(Repo.all(GdCollabManager.Collabs.Collab) |> Repo.preload([:collab_participants]))

      assert [collab] = GdCollabManager.Collabs.get_user_collabs(user)

      assert collab.name == collab_name
      assert collab.description == "test description"
      assert collab.collab_participants |> Enum.count() == 1
      assert collab.collab_participants |> Enum.at(0) |> then(& &1.user_id) == user.id
      assert collab.collab_participants |> Enum.at(0) |> then(& &1.role) == "host"
    end

    test "creates a collab with members", %{conn: conn, user: user} do
      collab_name = unique_collab_name()
      member_user = user_fixture()

      assert GdCollabManager.Collabs.get_user_collabs(member_user) == []

      {:ok, lv, _html} = live(conn, ~p"/my-collabs/new")

      {:error, {:live_redirect, %{to: redirect_to}}} =
        form =
        form(lv, "#new-collab-form", %{
          "name" => collab_name,
          "description" => "test description"
        })
        |> render_submit(%{"users" => "[#{member_user.id}]"})

      {:ok, _lv, html} = form |> follow_redirect(conn, redirect_to)

      assert html =~ collab_name

      assert [collab] =
               GdCollabManager.Collabs.get_user_collabs(user)
               |> Repo.preload([:collab_participants])

      assert [member_collab] = GdCollabManager.Collabs.get_user_collabs(member_user)

      assert collab.id == member_collab.id

      assert Enum.count(collab.collab_participants) == 2
      assert Enum.find(collab.collab_participants, &(&1.user_id == user.id)).role == "host"

      assert Enum.find(collab.collab_participants, &(&1.user_id == member_user.id)).role ==
               "member"
    end

    test "displays the user's email in the multi-select", %{conn: conn, user: user} do
      collab_name = unique_collab_name()

      email = "asdfghjklñ@rand.com"
      member_user = user_fixture(%{email: email})

      first_letters_of_member_user_email = member_user |> then(& &1.email) |> String.slice(0..3)

      {:ok, lv, _html} = live(conn, ~p"/my-collabs/new")

      # multi_select_name = GdCollabManagerWeb.MultiSelectComponent.search_input_name("user-select")

      # Pending until i know how to do it

      # assert lv
      #        |> form("#new-collab-form", %{
      #          multi_select_name => first_letters_of_member_user_email
      #        })
      #        |> open_browser()
      #        |> render_submit() =~ email
    end
  end
end
