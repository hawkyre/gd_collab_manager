defmodule GdCollabManagerWeb.MultiSelectComponent do
  use GdCollabManagerWeb, :live_component

  # alias GdCollabManager.MultiSelect

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:search_value, "")
      |> assign(:filtered_options, [])
      |> assign(:selected, [])
      |> assign(:focused, false)

    {:ok, socket}
  end

  def search_input_name(id), do: "__" <> id <> "-track-input"
  def option_container_id(id), do: "__" <> id <> "-track-input"

  @impl true
  def update(assigns, socket) do
    {:ok,
     assign(socket, assigns)
     |> assign(:search_name, search_input_name(assigns.id))
     |> assign(
       :filtered_options,
       if(not Map.has_key?(assigns, :length_threshold) or assigns.length_threshold == 0,
         do: assigns.options,
         else: []
       )
     )}
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :value, :list, default: []
  attr :label, :string, default: ""

  # Must be a list of %{id: string, label: string}
  attr :options, :list, default: []

  attr :length_threshold, :integer, default: 0
  attr :on_input_change_info, :atom, default: nil
  attr :on_select_option, :string, default: nil
  attr :on_create_option, :any, default: nil
  attr :phx_target, :atom, default: nil

  def render(assigns) do
    assigns =
      assigns
      |> maybe_transform_options()
      |> ensure_values_are_valid!()
      |> assign(:can_select, String.length(assigns.search_value) >= assigns.length_threshold)
      |> assign(
        :can_create,
        Map.has_key?(assigns, :on_create_option) and is_function(assigns.on_create_option)
      )

    ~H"""
    <div>
      <input type="hidden" name={@name} value={@selected |> Jason.encode!()} />
      <.label :if={Map.has_key?(assigns, :label)} for={@id}><%= @label %></.label>
      
      <div class={[
        "flex flex-wrap gap-1 mt-1 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm border-zinc-300 focus:border-zinc-400 max-w-[100%]"
      ]}>
        <%= for option_id <- @selected do %>
          <span class="text-sm text-zinc-700 rounded-md bg-zinc-100 px-2 py-1">
            <%= option_id_to_label(@options, option_id) %>
          </span>
        <% end %>
      </div>
      
      <div phx-click-away="input_blur" phx-target={@myself}>
        <.input
          id={@id}
          name={@search_name}
          value={@search_value}
          phx-change="input_change"
          phx-target={@myself}
          phx-focus="input_focus"
          type="text"
          autocomplete="off"
        />
        <div class="relative" phx-target={@myself}>
          <div
            :if={@can_select and length(@filtered_options) > 0 and @focused}
            id={option_container_id(@id)}
            class="bg-white absolute mt-2 rounded-md border border-zinc-300 divide-y divide-zinc-200 overflow-y-auto max-h-[200px] w-full max-w-[100%] shadow-md"
          >
            <%= for %{id: option_id, label: label} <- @filtered_options do %>
              <button
                type="button"
                class={[
                  "px-2 py-1 flex items-center justify-between gap-1 w-full",
                  Enum.member?(@selected, option_id) && "bg-zinc-100"
                ]}
                phx-click="select"
                phx-target={@myself}
                phx-value-option={option_id}
              >
                <span class="text-sm"><%= label %></span>
                <div
                  :if={Enum.member?(@selected, option_id)}
                  class="h-4 w-4 text-sm flex items-center justify-center"
                >
                  ✅
                </div>
              </button>
            <% end %>
          </div>
        </div>
      </div>
      
      <p :if={not @can_select} class="text-sm px-2 py-1 text-zinc-800 bg-zinc-100 rounded-md mt-1">
        Please, type at least <%= @length_threshold %> characters to select options
      </p>
      
      <p
        :if={not @can_create and @can_select and length(@filtered_options) == 0}
        class="text-sm px-2 py-1 text-zinc-800 bg-zinc-100 rounded-md mt-1"
      >
        There are no options available
      </p>
      
      <button
        :if={@search_value != "" and @can_create and @can_select and length(@filtered_options) == 0}
        type="button"
        class="text-sm px-2 py-1 text-zinc-800 bg-zinc-100 rounded-md mt-1"
        phx-click="create_option"
        phx-value-new-option={@search_value}
        phx-target={@myself}
      >
        + Create option "<%= @search_value %>"
      </button>
    </div>
    """
  end

  @impl true
  def handle_event(
        "input_change",
        params,
        socket
      ) do
    search_value = Map.get(params, socket.assigns.search_name)

    if Map.has_key?(socket.assigns, :on_input_change_info) do
      send(
        self(),
        {socket.assigns.on_input_change_info, %{id: socket.assigns.id, value: search_value}}
      )
    end

    filtered_options =
      socket.assigns.options
      |> Enum.filter(&String.contains?(&1.label, search_value))

    {:noreply,
     socket |> assign(:filtered_options, filtered_options) |> assign(:search_value, search_value)}
  end

  @impl true
  def handle_event(
        "select",
        %{"option" => value},
        socket
      ) do
    value = String.to_integer(value)

    if Map.has_key?(socket.assigns, :on_select_option_info) do
      send(self(), {socket.assigns.on_select_option_info, %{id: socket.assigns.id, value: value}})
    end

    case Enum.member?(socket.assigns.selected, value) do
      true ->
        {:noreply, socket |> assign(:selected, List.delete(socket.assigns.selected, value))}

      false ->
        {:noreply, socket |> assign(:selected, socket.assigns.selected ++ [value])}
    end
  end

  def handle_event(
        "create_option",
        %{"new-option" => value},
        socket
      ) do
    case socket.assigns.on_create_option.(value) do
      {:ok, new_option_id} ->
        {:noreply,
         socket |> assign(selected: socket.assigns.selected ++ [new_option_id], search_value: "")}

      _ ->
        {:noreply, socket |> assign(:search_value, "")}
    end
  end

  def handle_event(
        "input_focus",
        _params,
        socket
      ) do
    {:noreply, assign(socket, :focused, true)}
  end

  def handle_event(
        "input_blur",
        _params,
        socket
      ) do
    {:noreply, assign(socket, :focused, false)}
  end

  defp transform_string_to_option_map(option), do: %{id: option.id, label: option.label}

  defp maybe_transform_options(%{options: options} = assigns) do
    if Enum.all?(options, &is_binary/1) do
      assign(assigns, :options, Enum.map(options, &transform_string_to_option_map/1))
    else
      assigns
    end
  end

  defp ensure_option_is_valid!(option) do
    if not is_map(option) or not Map.has_key?(option, :id) or not Map.has_key?(option, :label) do
      raise "options must be a list of maps with id and label keys"
    end

    :ok
  end

  defp ensure_length_threshold_is_valid!(length_threshold) do
    if length_threshold < 0 do
      raise "length_threshold must be a positive integer"
    end

    :ok
  end

  defp ensure_values_are_valid!(%{options: options, length_threshold: length_threshold} = assigns) do
    ensure_length_threshold_is_valid!(length_threshold)
    Enum.each(options, &ensure_option_is_valid!/1)

    assigns
  end

  defp ensure_values_are_valid!(_), do: raise("Invalid values")

  defp option_id_to_label(options, id) do
    case(Enum.find(options, &(&1.id == id))) do
      %{label: label} -> label
      _ -> nil
    end
  end
end
