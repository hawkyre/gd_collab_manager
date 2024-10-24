defmodule GdCollabManagerWeb.Collabs.CollabInstanceLive do
  use GdCollabManagerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.h1><%= @collab.name %></.h1>

    <div>
      <%= live_render(@socket, GdCollabManagerWeb.CollabTools.ToDoListLive,
        id: "to_do_list",
        session: %{"collab" => @collab, "current_user" => @current_user}
      ) %>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    collab_id = params["collab_id"]

    collab = GdCollabManager.Collabs.get_collab(socket.assigns.current_user, collab_id)

    case collab do
      nil -> {:ok, redirect(socket, to: "/my-collabs")}
      _ -> {:ok, socket |> assign(collab: collab)}
    end
  end
end
