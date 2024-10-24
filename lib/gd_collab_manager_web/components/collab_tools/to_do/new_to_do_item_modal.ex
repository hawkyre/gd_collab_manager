defmodule GdCollabManagerWeb.CollabTools.ToDo.NewToDoItemModal do
  alias GdCollabManager.Utils.DateUtils
  alias GdCollabManager.ToDoLists
  alias GdCollabManager.CollabTools.ToDo.NewToDoItem
  use GdCollabManagerWeb, :live_component

  attr :new_item, :map, required: true
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
          for={@new_item}
          phx-change="validate"
          phx-submit="on_create_item"
          class="flex flex-col gap-4 justify-between items-start py-2 pl-3 pr-2"
          phx-target={@myself}
        >
          <div>
            <h1 class="text-3xl mb-6">Let's create a new item</h1>
            
            <.input name="title" label="Title" field={f[:title]} placeholder="Add a new to-do item" />
          </div>
          
          <div>
            <div>
              <p class="text-sm mb-1 font-semibold">Set a due date</p>
              
              <input
                type="text"
                name="due_day"
                value={f[:due_day].value}
                class="w-[100px] rounded-l-md border border-zinc-300 focus:outline-none"
              />
              <select
                name="due_month"
                value={f[:due_month].value}
                class="border border-zinc-300 focus:outline-none"
              >
                <option value="1" selected={f[:due_month].value == "1"}>January</option>
                
                <option value="2" selected={f[:due_month].value == "2"}>February</option>
                
                <option value="3" selected={f[:due_month].value == "3"}>March</option>
                
                <option value="4" selected={f[:due_month].value == "4"}>April</option>
                
                <option value="5" selected={f[:due_month].value == "5"}>May</option>
                
                <option value="6" selected={f[:due_month].value == "6"}>June</option>
                
                <option value="7" selected={f[:due_month].value == "7"}>July</option>
                
                <option value="8" selected={f[:due_month].value == "8"}>August</option>
                
                <option value="9" selected={f[:due_month].value == "9"}>September</option>
                
                <option value="10" selected={f[:due_month].value == "10"}>October</option>
                
                <option value="11" selected={f[:due_month].value == "11"}>November</option>
                
                <option value="12" selected={f[:due_month].value == "12"}>December</option>
              </select>
              
              <input
                type="text"
                name="due_year"
                value={f[:due_year].value}
                class="w-[150px] rounded-r-md border border-zinc-300 focus:outline-none"
              />
            </div>
            
            <%= for {error, _} <- Keyword.get_values(f.errors, :due_date) do %>
              <.error for="due_date"><%= error %></.error>
            <% end %>
          </div>
          
          <div>
            <p class="text-sm font-semibold -mb-1">Select tags</p>
            
            <.live_component
              module={GdCollabManagerWeb.MultiSelectComponent}
              id="multi-select-tags"
              class="w-full"
              name="tags"
              options={@collab.tags |> Enum.map(&transform_tag_to_option/1)}
              on_create_option={fn tag -> create_new_tag(assigns, tag) end}
            />
          </div>
          
          <div>
            <p class="text-sm font-semibold -mb-1">Select users for the task</p>
            
            <.live_component
              module={GdCollabManagerWeb.MultiSelectComponent}
              id="multi-select-responsibles"
              class="w-full"
              name="responsibles"
              options={@collab.collab_participants |> Enum.map(&transform_participant_to_option/1)}
            />
          </div>
          
          <.button>
            <p>Add new item</p>
          </.button>
        </.form>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    form =
      %NewToDoItem{}
      |> NewToDoItem.changeset(params)
      |> to_form(action: :validate)

    {:noreply, socket |> assign(new_item: form)}
  end

  def handle_event("on_create_item", %{"title" => title} = params, socket) do
    new_to_do =
      %{
        title: title,
        creator_id: socket.assigns.current_user.id,
        collab_id: socket.assigns.collab.id,
        to_do_item_tags: create_tags(params),
        to_do_item_responsibles: create_responsibles(params, socket.assigns.collab.id),
        due_by: DateUtils.format_due_date(params)
      }
      |> ToDoLists.create_to_do()

    case new_to_do do
      {:ok, to_do} ->
        broadcast_to_topic(socket.assigns.collab_topic, "to_do_item:created", to_do)

        {:noreply,
         socket
         |> put_flash(:info, "New item created successfully")
         #  https://fly.io/phoenix-files/server-triggered-js/
         |> push_event("js-exec", %{
           to: "##{socket.assigns.id}",
           attr: "data-on-close"
         })
         |> assign(new_item: to_form(%{}))}

      {:error, changeset} ->
        IO.inspect(["Error creating to-do", changeset])
        {:noreply, socket}
    end
  end

  def create_new_tag(assigns, tag) do
    {:ok, new_tag} = ToDoLists.create_tag(%{collab_id: assigns.collab.id, tag: tag})

    broadcast_to_topic(assigns.collab_topic, "tag:created", new_tag)

    {:ok, new_tag.id}
  end

  # def handle_event("on_select_tag", %{"option" => tag}, socket) do
  #   IO.inspect(socket.assigns.new_item)

  #   {:noreply,
  #    assign(socket,
  #      new_item: toggle_tag(socket.assigns.new_item.data, tag)
  #    )}
  # end

  # defp toggle_tag(to_do_item, tag) when is_binary(tag),
  #   do: toggle_tag(to_do_item, String.to_integer(tag))

  # defp toggle_tag(to_do_item, tag) do
  #   IO.inspect(to_do_item)
  #   IO.inspect(to_do_item.data)

  #   tags = to_do_item.data.tags |> Jason.decode!()

  #   tags =
  #     if Enum.member?(tags, tag),
  #       do: List.delete(tags, tag),
  #       else: tags ++ [tag]

  #   NewToDoItem.changeset(to_do_item, %{"tags" => tags |> Jason.encode!()})
  #   |> IO.inspect()
  #   |> to_form(action: :validate)
  #   |> IO.inspect()
  # end

  def handle_info({:on_input_change_tag, %{id: "multi-select-tags", value: value}}, socket)
      when length(value) <= 2 do
    {:noreply, assign(socket, user_list: [])}
  end

  defp create_responsibles(params, collab_id) do
    params["responsibles"]
    |> Jason.decode!()
    |> Enum.map(&transform_responsible_id_to_item_responsible(&1, collab_id))
  end

  defp create_tags(params) do
    params["tags"]
    |> Jason.decode!()
    |> Enum.map(&transform_tag_id_to_item_tag/1)
  end

  defp transform_tag_id_to_item_tag(tag_id) do
    %{tag_id: tag_id}
  end

  defp transform_responsible_id_to_item_responsible(responsible_id, collab_id) do
    %{user_id: responsible_id, collab_id: collab_id}
  end

  defp transform_tag_to_option(tag) do
    %{id: tag.id, label: tag.tag}
  end

  defp transform_participant_to_option(participant) do
    %{id: participant.user_id, label: participant.user.username}
  end
end

#
