defmodule GdCollabManagerWeb.Inputs.HiddenEditableInput do
  use GdCollabManagerWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:clicked, false)

    {:ok, socket}
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :value, :string, required: true
  attr :class, :string, default: nil
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :clicked, :boolean, default: false

  attr :rest, :global,
    include:
      ~w(accept autocomplete capture cols disabled form list max maxlength min minlength multiple pattern placeholder readonly required rows size step)

  @impl true
  def render(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
         <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "mt-1 w-full h-full"
    ]}>
      <span
        :if={not @clicked}
        class={[
          "block w-full h-full"
        ]}
        phx-click="on-click-input"
      >
        <%= @value %>
      </span>
      
      <input
        :if={@clicked}
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-1 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm border-zinc-300 focus:border-zinc-400"
        ]}
        phx-click-away="on-click-out-of-input"
        {@rest}
      />
    </div>
    """
  end

  @impl true
  def handle_event("on-click-input", _, socket) do
    {:noreply, assign(socket, clicked: true)}
  end

  def handle_event("on-click-out-of-input", params, socket) do
    IO.inspect(params)
    # Save?
    {:noreply, assign(socket, clicked: false)}
  end
end
