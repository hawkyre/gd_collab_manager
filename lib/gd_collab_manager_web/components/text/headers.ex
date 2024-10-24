defmodule GdCollabManagerWeb.Text.Headers do
  use Phoenix.Component

  @doc ~S"""
  Renders a header 1 with title.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def h1(assigns) do
    ~H"""
    <h1 class={[@class, "text-4xl font-semibold"]}><%= render_slot(@inner_block) %></h1>
    """
  end

  @doc ~S"""
  Renders a header 2 with title.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def h2(assigns) do
    ~H"""
    <h2 class={[@class, "text-3xl font-semibold"]}><%= render_slot(@inner_block) %></h2>
    """
  end

  @doc ~S"""
  Renders a header 3 with title.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def h3(assigns) do
    ~H"""
    <h3 class={[@class, "text-2xl font-semibold"]}><%= render_slot(@inner_block) %></h3>
    """
  end

  @doc ~S"""
  Renders a header 4 with title.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def h4(assigns) do
    ~H"""
    <h4 class={[@class, "text-xl font-semibold"]}><%= render_slot(@inner_block) %></h4>
    """
  end
end
