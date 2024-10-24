defmodule GdCollabManager.Contexts.CollabParts do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias GdCollabManager.CollabTools.Parts.CollabPart
  alias GdCollabManager.Repo

  @doc """
  Returns true if a collab part with the given label exists.
  """
  @spec exists_part_with_label?(integer(), String.t()) :: boolean()
  def exists_part_with_label?(collab_id, label) do
    Repo.exists?(
      from cp in CollabPart,
        where: cp.label == ^label and cp.collab_id == ^collab_id
    )
  end

  @spec create_part(map()) :: {:ok, CollabPart.t()} | {:error, Ecto.Changeset.t()}
  def create_part(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:collab_part, CollabPart.new() |> CollabPart.changeset(attrs))
    |> Multi.run(:update_orders, fn repo, %{collab_part: collab_part} ->
      parts = repo.all(from(cp in CollabPart, where: cp.collab_id == ^collab_part.collab_id))
      previous_part = Enum.find(parts, fn part -> part.id == attrs.previous_part_id end)

      parts
      |> Enum.map(fn part ->
        cond do
          previous_part == nil and part.id == collab_part.id ->
            %{part | order: -1}

          previous_part == nil ->
            part

          part.id == collab_part.id ->
            %{part | order: previous_part.order + 1}

          part.order > previous_part.order ->
            %{part | order: part.order + 1}

          true ->
            part
        end
      end)
      |> Enum.sort_by(& &1.order)
      |> Enum.with_index()
      |> Enum.map(fn {part, i} ->
        repo.update!(part |> CollabPart.changeset(%{order: i + 1}))
      end)
      |> then(&{:ok, &1})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{collab_part: collab_part}} -> {:ok, collab_part}
      {:error, :collab_part, changeset, _} -> {:error, changeset}
      {:error, :update_orders, changeset, _} -> {:error, changeset}
    end
  end

  def update_part(collab_part_id, attrs) do
    Repo.get!(CollabPart, collab_part_id)
    |> CollabPart.changeset(attrs)
    |> Repo.update()
    |> preload_collab_part()
  end

  defp preload_collab_part({:error, _} = p), do: p

  defp preload_collab_part({:ok, %CollabPart{} = part}) do
    {:ok, preload(part)}
  end

  defp preload_collab_part(%CollabPart{} = part) do
    preload(part)
  end

  defp preload(%CollabPart{} = part), do: part |> Repo.preload(to_do_item: [:responsibles, :tags])
end
