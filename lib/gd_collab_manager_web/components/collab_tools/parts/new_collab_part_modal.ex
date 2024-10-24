defmodule GdCollabManagerWeb.CollabTools.Parts.NewCollabPartModal do
  alias GdCollabManager.Utils.DateUtils
  alias GdCollabManager.Contexts.CollabParts
  use GdCollabManagerWeb, :live_component

  alias GdCollabManager.CollabTools.Part.NewCollabPart

  attr :id, :string, required: true
  attr :part, :map, required: true
  attr :current_user, :map, required: true
  attr :collab, :map, required: true
  attr :collab_topic, :string, required: true
  attr :modal_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.modal id={@id} on_close={hide_modal(@id)}>
        <.form
          :let={f}
          for={@part}
          phx-change="validate"
          phx-submit="on_create_part"
          class="flex flex-col gap-4 justify-between items-start py-2 pl-3 pr-2"
          phx-target={@myself}
        >
          <div class="flex flex-col gap-4">
            <h1 class="text-3xl mb-6">Let's create a new part</h1>
             <.input name="label" label="Label (unique)" field={f[:label]} />
            <div>
              <.input
                type="select"
                name="previous_part_id"
                label="Previous part"
                field={f[:previous_part_id]}
                prompt="None (first part)"
                options={
                  @collab.parts |> Enum.sort_by(& &1.order) |> Enum.map(&transform_part_to_option/1)
                }
              />
            </div>
            
            <div class="flex gap-2">
              <.input name="start_time" label="Start time" field={f[:start_time]} class="border-r-0" />
              <.input name="end_time" label="End time" field={f[:end_time]} class="border-l-0" />
            </div>
            
            <.input type="textarea" name="comments" label="Comments (optional)" field={f[:comments]} />
            <div>
              <p class="text-sm font-semibold -mb-1">Part creator/s</p>
              
              <.live_component
                module={GdCollabManagerWeb.MultiSelectComponent}
                id="multi-select-responsibles"
                class="w-full"
                name="responsibles"
                options={@collab.collab_participants |> Enum.map(&transform_participant_to_option/1)}
              />
            </div>
            
            <.button>Create part</.button>
          </div>
        </.form>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    IO.inspect(params)

    params = change_time_when_part_changes(params, socket.assigns.collab)

    form =
      NewCollabPart.new(%{collab_id: socket.assigns.collab.id})
      |> NewCollabPart.changeset(params)
      |> to_form(action: :validate)

    {:noreply, socket |> assign(part: form)}
  end

  def handle_event("on_create_part", params, socket) do
    new_part =
      %{
        label: params["label"],
        comments: params["comments"],
        start_time: params["start_time"] |> String.to_integer(),
        end_time: params["end_time"] |> String.to_integer(),
        collab_id: socket.assigns.collab.id,
        previous_part_id: maybe_parse_integer(params["previous_part_id"]),
        to_do_item:
          create_to_do_item(params, socket.assigns.current_user.id, socket.assigns.collab.id)
      }
      |> CollabParts.create_part()

    case new_part do
      {:ok, part} ->
        broadcast_to_topic(socket.assigns.collab_topic, "part:created", part)

        {:noreply,
         socket
         |> put_flash(:info, "New part created successfully")
         #  https://fly.io/phoenix-files/server-triggered-js/
         |> push_event("js-exec", %{
           to: "##{socket.assigns.id}",
           attr: "data-on-close"
         })
         |> assign(part: to_form(%{}))}

      {:error, changeset} ->
        IO.inspect(["Error creating part", changeset])
        {:noreply, socket}
    end
  end

  defp maybe_parse_integer(string) do
    case Integer.parse(string) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp transform_part_to_option(part) do
    {part.label, part.id}
  end

  defp transform_participant_to_option(participant) do
    %{id: participant.user_id, label: participant.user.username}
  end

  defp create_to_do_item(params, user_id, collab_id) do
    %{
      title: "Finish part #{params["label"]}",
      creator_id: user_id,
      collab_id: collab_id,
      to_do_item_tags: [],
      to_do_item_responsibles: create_responsibles(params, collab_id),
      due_by: DateUtils.format_due_date(params)
    }
  end

  defp create_responsibles(params, collab_id) do
    params["responsibles"]
    |> Jason.decode!()
    |> Enum.map(&transform_responsible_id_to_part_responsible(&1, collab_id))
  end

  defp transform_responsible_id_to_part_responsible(responsible_id, collab_id) do
    %{user_id: responsible_id, collab_id: collab_id}
  end

  defp change_time_when_part_changes(
         %{"_target" => ["previous_part_id"], "previous_part_id" => id} = params,
         collab
       ) do
    id = if id == "", do: 0, else: String.to_integer(id)

    {part, next_part} = get_parts_from_previous_part_id(id, collab)
    {previous_part_end_time, next_part_start_time} = get_order_between_parts(part, next_part)

    params
    |> Map.merge(%{
      "start_time" => "#{previous_part_end_time}",
      "end_time" => "#{next_part_start_time}"
    })
  end

  defp change_time_when_part_changes(params, _collab) do
    params
  end

  defp get_parts_from_previous_part_id(part_id, collab) do
    case collab.parts |> Enum.find(&(&1.id == part_id)) do
      nil -> {nil, collab.parts |> Enum.sort_by(& &1.order) |> Enum.at(0)}
      part -> {part, collab.parts |> Enum.find(&(&1.order == part.order + 1))}
    end
  end

  defp get_order_between_parts(nil, nil), do: {0, 0}
  defp get_order_between_parts(nil, next_part), do: {0, next_part.start_time}
  defp get_order_between_parts(part, nil), do: {part.end_time, 0}
  defp get_order_between_parts(part, next_part), do: {part.end_time, next_part.start_time}
end

#
