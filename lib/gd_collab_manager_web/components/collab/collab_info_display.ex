defmodule GdCollabManagerWeb.Collab.CollabInfoDisplay do
  use GdCollabManagerWeb, :html

  attr :collab, :map, required: true

  def collab_info_display(assigns) do
    assigns = assign_new(assigns, :collab_url, fn -> "/my-collabs/#{assigns.collab.id}" end)

    ~H"""
    <a
      href={@collab_url}
      class="flex flex-col items-start gap-2 py-4 px-6 hover:bg-zinc-100 border border-zinc-300 rounded-md"
    >
      <div class="flex items-center gap-2">
        <span class="font-semibold"><%= @collab.name %></span>
      </div>
      
      <div class="flex items-center gap-2">
        <span class="text-sm">
          Created on <%= Utils.DateFormatter.format_date(@collab.inserted_at) %>
        </span>
      </div>
      
      <div class="flex items-center gap-2">
        <span class="text-sm font-semibold">
          <%= @collab.collab_participants |> length %> members
        </span>
      </div>
    </a>
    """
  end
end
