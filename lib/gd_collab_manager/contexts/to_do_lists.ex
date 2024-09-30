defmodule GdCollabManager.ToDoLists do
  @moduledoc """
  The ToDo context.
  """
  alias GdCollabManager.ToDo.Tag
  alias GdCollabManager.Repo
  alias GdCollabManager.ToDo.ToDoItem

  import Ecto.Query, warn: false

  @spec create_to_do(map()) :: {:ok, ToDoItem.t()} | {:error, Ecto.Changeset.t()}
  def create_to_do(attrs \\ %{}) do
    ToDoItem.new()
    |> ToDoItem.changeset(attrs)
    |> Repo.insert()
    |> maybe_preload([:tags, :responsibles])
  end

  @spec update_to_do_item(integer(), map()) :: {:ok, ToDoItem.t()} | {:error, Ecto.Changeset.t()}
  def update_to_do_item(id, attrs) do
    Repo.get!(ToDoItem, id)
    |> ToDoItem.changeset(attrs)
    |> Repo.update()
    |> maybe_preload([:tags, :responsibles])
  end

  @spec create_tag(map()) :: {:ok, Tag.t()} | {:error, Ecto.Changeset.t()}
  def create_tag(attrs) do
    Tag.new()
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  defp maybe_preload({:ok, result}, preloads) do
    {:ok, Repo.preload(result, preloads)}
  end

  defp maybe_preload({:error, error}, _), do: {:error, error}
end
