defmodule GdCollabManagerWeb.Collabs.NewCollabLive do
  alias GdCollabManager.CollabTools.ToDo.NewCollab
  alias GdCollabManagerWeb.MultiSelectComponent
  use GdCollabManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(collab: to_form(NewCollab.new() |> NewCollab.changeset()))
     |> assign(selected_users: [])
     |> assign(user_list: [])}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:user_options, Enum.map(assigns.user_list, &%{id: &1.id, label: &1.email}))
      |> assign(:selected_users, [
        assigns.current_user.email | Enum.map(assigns.selected_users, & &1.email)
      ])

    ~H"""
    <h1>Create new collab</h1>

    <.simple_form :let={f} for={@collab} phx-submit="save" phx-change="validate" id="new-collab-form">
      <.input field={f[:name]} name="name" label="Name" />
      <.input field={f[:description]} name="description" label="Description" />
      <.live_component
        module={MultiSelectComponent}
        id="user-select"
        name="users"
        label="Users"
        options={@user_options}
        length_threshold={2}
        on_input_change_info={:update_select_filter}
      /> <%!-- <.input type="file" field={f[:image_url]} label="Collab Image" /> --%>
      <:actions>
        <.button type="submit">Create</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    form =
      NewCollab.new()
      |> NewCollab.changeset(params)
      |> to_form(action: :validate)

    {:noreply, socket |> assign(collab: form)}
  end

  def handle_event("save", collab_params, socket) do
    collab_params = Map.update!(collab_params, "users", fn users -> Jason.decode!(users) end)
    collab = GdCollabManager.Collabs.create_collab(socket.assigns.current_user.id, collab_params)

    case collab do
      {:ok, collab} ->
        {:noreply,
         socket
         |> put_flash(:info, "Collab created successfully")
         |> push_navigate(to: ~p"/my-collabs/#{collab.id}")}

      {:error, _changeset} ->
        {:noreply, socket}
    end

    # redirecto to collab page
  end

  @impl true
  def handle_info({:update_select_filter, %{id: "user-select", value: value}}, socket)
      when length(value) <= 2 do
    {:noreply, assign(socket, user_list: [])}
  end

  def handle_info({:update_select_filter, %{id: "user-select", value: value}}, socket) do
    new_users =
      GdCollabManager.Accounts.get_users_with_email_like(value)
      |> Enum.map(&%{email: &1.email, id: &1.id})
      |> Enum.filter(&(&1.email != socket.assigns.current_user.email))

    {:noreply, assign(socket, user_list: new_users)}
  end

  def handle_info({:select_option, %{id: "user-select", value: value}}, socket) do
    new_selected_users =
      toggle_selected_user(socket.assigns, value)

    {:noreply, assign(socket, selected_users: new_selected_users)}
  end

  defp toggle_selected_user(%{selected_users: selected_users, user_list: user_list}, email) do
    if Enum.find(selected_users, &(&1.email == email)),
      do: Enum.filter(selected_users, &(&1.email != email)),
      else: [
        user_list |> Enum.find(&(&1.email == email))
        | selected_users
      ]
  end
end
