defmodule GdCollabManagerWeb.Collabs.MyCollabsLive do
  use GdCollabManagerWeb, :live_view

  alias GdCollabManager.Collabs
  import GdCollabManagerWeb.Collab.CollabInfoDisplay

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-xl font-semibold mb-4">My Collabs</h1>

    <ul class="flex flex-col gap-4">
      <%= for collab <- @collabs do %>
        <.collab_info_display collab={collab} />
      <% end %>
      
      <li>
        <.button_link to="/my-collabs/new" variant="default">Create collab</.button_link>
      </li>
    </ul>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, collabs: Collabs.get_user_collabs(socket.assigns.current_user))}
  end
end
