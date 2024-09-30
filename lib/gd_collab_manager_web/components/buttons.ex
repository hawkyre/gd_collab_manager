defmodule GdCollabManagerWeb.Buttons do
  use Phoenix.Component

  @doc ~S"""
  Renders a link styled as a button.

  ## Examples

      <.button_link to="/foo">Send!</.button_link>
  """
  attr :to, :string, required: true
  attr :class, :string, default: nil

  attr :variant, :string,
    values: ~w(default secondary link),
    default: "link",
    doc: "The button variant to use."

  attr :size, :string,
    values: ~w(default sm lg link),
    default: "default",
    doc: "The button size to use."

  attr :rest, :global

  slot :inner_block, required: true

  def button_link(assigns) do
    assigns = assigns |> assign(:variant_classes, get_variant_classes(assigns))

    ~H"""
    <a href={@to} class={[@variant_classes, @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  @doc """
  Renders a simple button.

  ## Examples

      <.button>Send!</.button>
  """
  attr :type, :string, default: nil
  attr :on_click, :any, default: nil
  attr :class, :string, default: nil

  attr :variant, :string,
    values: ~w(default secondary),
    default: "default",
    doc: "The button variant to use."

  attr :size, :string,
    values: ~w(default sm lg icon),
    default: "default",
    doc: "The button size to use."

  attr :rest, :global

  slot :inner_block, required: true

  def button(assigns) do
    assigns = assigns |> assign(:variant_classes, get_variant_classes(assigns))

    ~H"""
    <button type={@type} phx-click={@on_click} class={[@variant_classes, @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @variants %{
    variant: %{
      "default" =>
        "inline-flex bg-primary text-white rounded-md font-semibold shadow hover:bg-primary/90",
      "secondary" => "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
      "link" => "text-primary underline-offset-4 hover:underline"
    },
    size: %{
      "default" => "px-4 py-2",
      "sm" => "rounded-md px-3 text-xs",
      "lg" => "rounded-md px-8",
      "icon" => "h-9 w-9 flex items-center justify-center",
      "link" => ""
    }
  }

  @default_variants %{
    variant: "default",
    size: "default"
  }

  @global_classes "transition-all"

  defp get_variant_classes(assigns) do
    variant_keys = Map.take(assigns, ~w(variant size)a)
    variant_keys = Map.merge(@default_variants, variant_keys)

    Enum.map_join(variant_keys, " ", fn {key, value} -> @variants[key][value] end) <>
      " " <> @global_classes
  end
end
