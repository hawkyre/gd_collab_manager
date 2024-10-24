defmodule GdCollabManagerWeb.CollabTools.ToDo.ToDoItem do
  alias GdCollabManager.Utils.DateUtils
  use GdCollabManagerWeb, :live_component

  attr :item, :map, required: true
  attr :creators, :list, required: true

  def render(assigns) do
    assigns =
      assign(assigns,
        id: "item-" <> to_string(assigns.item.id),
        formatted_due_date: Utils.DateFormatter.format_date(assigns.item.due_by),
        creator_username: get_creator_username(assigns.item.creator_id, assigns.creators),
        days_until_due_text:
          if(assigns.item.due_by,
            do: DateUtils.days_until_due(assigns.item.due_by),
            else: nil
          )
      )

    ~H"""
    <div class="flex flex-row gap-2 items-start">
      <input
        id={@id}
        type="checkbox"
        class="h-6 w-6"
        checked={@item.completed}
        phx-click="toggle_to_do_item"
        phx-value-id={@item.id}
        phx-value-toggle_to={not @item.completed}
      />
      <div class="flex flex-col gap-1">
        <label for={@id} class="text font-medium text-gray-900 h-6 self-start cursor-pointer">
          <%= @item.title %>
        </label>
        
        <div class="flex gap-1 text-sm text-gray-500 items-center">
          <span :if={@item.due_by}>
            Due <%= @formatted_due_date %> (<%= @days_until_due_text %>)
          </span>
           <span :if={is_nil(@item.due_by)} class="italic">No due date</span> <span>-</span>
          <span><%= @creator_username %></span> <span :if={length(@item.tags) > 0}>-</span>
          <%= for tag <- @item.tags do %>
            <span class="text-sm text-zinc-600 px-1 py-0.5 bg-zinc-100 rounded-md">
              <%= tag.tag %>
            </span>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def get_creator_username(creator_id, creators) do
    case Enum.find(creators, fn creator -> creator.user_id == creator_id end) do
      nil -> "Unknown"
      creator -> creator.user.username
    end
  end
end
