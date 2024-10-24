defmodule GdCollabManagerWeb.CollabTools.Parts.CollabPartRow do
  use GdCollabManagerWeb, :live_component

  attr :part, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="flex">
      <span class="text-sm text-zinc-600">#<%= @part.order %></span>
      <span class="text-sm text-zinc-600"><%= @part.label %></span>
    </div>
    """
  end
end
