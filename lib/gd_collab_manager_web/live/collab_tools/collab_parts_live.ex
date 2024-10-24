defmodule GdCollabManagerWeb.CollabTools.CollabPartsLive do
  alias GdCollabManager.Contexts.CollabParts
  alias GdCollabManager.Utils.DateUtils
  alias GdCollabManager.Utils.DurationUtils
  alias GdCollabManager.CollabTools.Part.NewCollabPart
  use GdCollabManagerWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    collab_id = params["collab_id"]

    collab = GdCollabManager.Collabs.get_collab(socket.assigns.current_user, collab_id)

    case collab do
      nil ->
        {:ok, redirect(socket, to: "/my-collabs")}

      _ ->
        topic = GdCollabManager.Collabs.generate_collab_topic(collab)
        subscribe_to_topic(topic)

        {:ok,
         socket
         |> assign(
           collab: collab,
           collab_topic: topic,
           part: to_form(NewCollabPart.new(%{collab_id: collab.id}) |> NewCollabPart.changeset())
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.h1>Collab parts</.h1>
    <.live_component
      module={GdCollabManagerWeb.Tables.TableWithEditableCells}
      id="parts-table"
      rows={@collab.parts}
    >
      <:col :let={part} label="Part"><%= part.label %></:col>
      <:col :let={part} label="Duration">
        <%= format_part_duration(part) %>
      </:col>
      <:col :let={part} label="Started on"><%= DateUtils.format_date(part.inserted_at) %></:col>

      <:col :let={part} label="Comments" editable={true} name="comments">
        <%= part.comments %>
      </:col>
      <:col
        :let={part}
        label="Status"
        name="status"
        editable={true}
        type="select"
        options={["open", "in progress", "done"]}
      >
        <%= part.status %>
      </:col>
      <:col :let={part} label="Creators">
        <%= format_part_responsibles(part) %>
      </:col>
    </.live_component>
    <.live_component
      module={GdCollabManagerWeb.CollabTools.Parts.NewCollabPartModal}
      id="new-collab-modal"
      part={@part}
      collab={@collab}
      current_user={@current_user}
      collab_topic={@collab_topic}
    />

    <.button variant="default" phx-click={show_modal("new-collab-modal")}>
      New collab part
    </.button>
    """
  end

  @impl true
  def handle_info({:on_update_cell, row_id, col_name, new_value}, socket) do
    row_attrs = %{col_name => new_value}

    {:ok, new_row} = update_cell(row_id, row_attrs)

    {:noreply, socket |> assign(collab: update_collab_row(socket.assigns.collab, new_row))}
  end

  defp format_part_duration(%{start_time: start_time, end_time: end_time}),
    do:
      "#{DurationUtils.seconds_to_mm_ss(start_time)} - #{DurationUtils.seconds_to_mm_ss(end_time)}"

  defp format_part_responsibles(%{to_do_item: %{responsibles: []}}), do: "-"

  defp format_part_responsibles(part) do
    part.to_do_item.responsibles |> Enum.map(& &1.username) |> Enum.join(", ")
  end

  defp update_collab_row(collab, row) do
    collab_parts =
      collab.parts
      |> Enum.map(fn part ->
        if part.id == row.id do
          IO.inspect([part, row])
          Map.merge(part, row)
        else
          part
        end
      end)

    Map.put(collab, :parts, collab_parts)
  end

  defp update_cell(row_id, attrs) do
    CollabParts.update_part(row_id, attrs)
  end
end
