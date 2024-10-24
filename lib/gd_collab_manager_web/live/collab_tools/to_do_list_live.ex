defmodule GdCollabManagerWeb.CollabTools.ToDoListLive do
  alias GdCollabManager.Collabs
  alias GdCollabManager.CollabTools.ToDo.NewToDoItem
  alias GdCollabManager.ToDoLists
  use GdCollabManagerWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    topic = Collabs.generate_collab_topic(session["collab"])
    subscribe_to_topic(topic)

    {:ok,
     socket
     |> assign(
       collab_topic: topic,
       collab: session["collab"],
       current_user: session["current_user"],
       new_item: to_form(NewToDoItem.new() |> NewToDoItem.changeset(%{}))
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.h1 class="mb-2">To-do list</.h1>
      
      <.button phx-click={show_modal("new-item-modal")} class="mb-4">
        Add new item
      </.button>
      
      <div class="flex flex-col gap-4">
        <%= for item <- Enum.sort_by(@collab.to_do_items, & &1.inserted_at) do %>
          <.live_component
            module={GdCollabManagerWeb.CollabTools.ToDo.ToDoItem}
            id={item.id}
            item={item}
            creators={@collab.collab_participants}
          />
        <% end %>
      </div>
      
      <.live_component
        module={GdCollabManagerWeb.CollabTools.ToDo.NewToDoItemModal}
        id="new-item-modal"
        new_item={@new_item}
        collab={@collab}
        current_user={@current_user}
        collab_topic={@collab_topic}
      />
    </div>
    """
  end

  @impl true
  def handle_event("toggle_to_do_item", %{"id" => id} = params, socket) do
    new_to_do_item =
      ToDoLists.update_to_do_item(id, %{completed: Map.get(params, "value", "") == "on"})

    case new_to_do_item do
      {:ok, to_do_item} ->
        broadcast_to_topic(socket.assigns.collab_topic, "to_do_item:updated", to_do_item)
        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(["Error updating to-do item", changeset])
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({"to_do_item:created", to_do}, socket) do
    {:noreply,
     socket
     |> assign(collab: add_to_do_item_to_collab(socket.assigns.collab, to_do))}
  end

  def handle_info({"to_do_item:updated", to_do}, socket) do
    {:noreply,
     socket
     |> assign(collab: update_to_do_item(socket.assigns.collab, to_do))}
  end

  def handle_info({"tag:created", new_tag}, socket) do
    {:noreply,
     socket
     |> assign(collab: add_tag_to_collab(socket.assigns.collab, new_tag))}
  end

  defp add_to_do_item_to_collab(collab, new_to_do) do
    %{collab | to_do_items: [new_to_do | collab.to_do_items] |> Enum.reverse()}
  end

  defp add_tag_to_collab(collab, new_tag) do
    %{collab | tags: [new_tag | collab.tags] |> Enum.reverse()}
  end

  defp update_to_do_item(collab, new_to_do) do
    %{
      collab
      | to_do_items:
          collab.to_do_items
          |> Enum.map(fn item ->
            if item.id == new_to_do.id, do: Map.merge(item, new_to_do), else: item
          end)
    }
  end
end
