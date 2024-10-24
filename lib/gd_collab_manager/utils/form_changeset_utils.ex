defmodule GdCollabManager.Utils.FormChangesetUtils do
  @moduledoc """
  This module contains utilities for working with changesets used by forms.
  """

  @doc """
  Validates that a string field is a string representation of a list of integers.

  ## Examples

      iex> changeset = Ecto.Changeset.change(%{field: "[1, 2, 3]"})
      iex> validate_string_array_of_integers(changeset, :field)
      %Ecto.Changeset{changes: %{field: [1, 2, 3]}, errors: [], data: %{field: "[1, 2, 3]"}}
  """
  @spec validate_string_array_of_integers(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate_string_array_of_integers(changeset, field) do
    field = changeset.changes[field]

    case field do
      nil ->
        changeset

      field ->
        case field
             |> Jason.decode!()
             |> Enum.all?(&is_integer/1) do
          true -> changeset
          false -> raise "Field #{field} must be a list of integers"
        end
    end
  end
end
