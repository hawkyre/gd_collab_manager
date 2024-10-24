defmodule GdCollabManagerWeb.Tables.TableWithEditableCells do
  use GdCollabManagerWeb, :live_component
  use Gettext, backend: GdCollabManagerWeb.Gettext

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"
  attr :edited_cell_id, :string, default: nil

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :name, :string
    attr :label, :string
    attr :editable, :boolean
    attr :type, :string
    attr :options, :list
    attr :multiple, :boolean
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  @impl true
  def render(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full" style="table-layout: fixed">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only"><%= gettext("Actions") %></span>
            </th>
          </tr>
        </thead>
        
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={Map.get(col, :editable) && "on_click"}
              phx-click-away={@edited_cell_id == cell_id(row, col) && "on_blur"}
              phx-target={@myself}
              phx-value-cell_id={cell_id(row, col)}
              class={["relative p-0", Map.get(col, :editable) && "cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span
                  :if={@edited_cell_id != cell_id(row, col)}
                  class={["relative", i == 0 && "font-semibold text-zinc-900"]}
                >
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
                
                <form
                  :if={@edited_cell_id == cell_id(row, col)}
                  class={[
                    "flex flex-row gap-2 items-center relative",
                    i == 0 && "font-semibold text-zinc-900"
                  ]}
                  phx-submit="on_update_cell"
                  phx-target={@myself}
                >
                  <input
                    :if={Map.get(col, :type, "text") == "text"}
                    class="h-6 px-1 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm border border-zinc-300 focus:border-zinc-400"
                    name="_"
                    value={Map.get(row, String.to_atom(col.name))}
                  />
                  <select
                    :if={Map.get(col, :type, "text") == "select"}
                    name="_"
                    class="p-0 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
                    multiple={Map.get(col, :multiple, false)}
                  >
                    <%= for option <- Map.get(col, :options) do %>
                      <option
                        value={option}
                        selected={option == Map.get(row, String.to_atom(col.name))}
                      >
                        <%= option %>
                      </option>
                    <% end %>
                  </select>
                  
                  <.button size="icon-small">
                    <.icon name="hero-check" class="h-4 w-4" />
                  </.button>
                </form>
              </div>
            </td>
            
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp cell_id(row, col) do
    "#{row.id}-#{col[:name]}"
  end

  defp cell_params(cell_id) do
    row_id = String.split(cell_id, "-") |> Enum.at(0) |> String.to_integer()
    col_name = String.split(cell_id, "-") |> Enum.at(1)

    %{row_id: row_id, col_name: col_name}
  end

  @impl true
  def handle_event("on_click", %{"cell_id" => cell_id}, socket) do
    {:noreply, socket |> assign(edited_cell_id: cell_id)}
  end

  @impl true
  def handle_event("on_blur", _, socket) do
    {:noreply, socket |> assign(edited_cell_id: nil)}
  end

  def handle_event("on_update_cell", %{"_" => new_value}, socket) do
    cell_id = socket.assigns.edited_cell_id
    on_update_cell(cell_id, new_value)
    {:noreply, socket |> assign(edited_cell_id: nil)}
  end

  defp on_update_cell(cell_id, new_value) do
    %{row_id: row_id, col_name: col_name} = cell_params(cell_id)

    send(self(), {:on_update_cell, row_id, col_name, new_value})
  end
end
