defmodule GdCollabManager.CollabTools.Part.NewCollabPart do
  alias GdCollabManager.Contexts.CollabParts
  use Ecto.Schema

  import Ecto.Changeset
  import GdCollabManager.Utils.FormChangesetUtils

  embedded_schema do
    field :label, :string
    field :previous_part_id, :integer
    field :comments, :string
    field :start_time, :integer
    field :end_time, :integer
    field :responsibles, :string
    field :collab_id, :integer
  end

  def new(attrs \\ %{}) do
    if not Map.has_key?(attrs, :collab_id) do
      raise "collab_id must be provided for the new collab part"
    end

    %__MODULE__{
      label: "",
      comments: "",
      start_time: 0,
      end_time: 0,
      responsibles: "[]",
      previous_part_id: nil
    }
    |> Map.merge(attrs)
  end

  def changeset(struct, params \\ %{}) do
    IO.inspect(params)

    struct
    |> cast(params, [:label, :previous_part_id, :comments, :start_time, :end_time, :responsibles])
    |> validate_required([
      :label,
      :start_time,
      :end_time,
      :responsibles
    ])
    |> validate_length(:label, min: 1, max: 100)
    |> validate_number(:start_time, greater_than_or_equal_to: 0)
    |> validate_number(:start_time,
      less_than_or_equal_to: get_end_time(params)
    )
    |> validate_number(:end_time, greater_than_or_equal_to: 0)
    |> validate_string_array_of_integers(:responsibles)
    |> validate_unique_label()
  end

  defp get_end_time(params) do
    if params["end_time"] != nil and String.length(params["end_time"]) > 0,
      do: params["end_time"] |> String.to_integer(),
      else: 0
  end

  defp validate_unique_label(changeset) do
    case changeset do
      %{changes: %{label: label, collab_id: collab_id}} ->
        if CollabParts.exists_part_with_label?(collab_id, label) do
          add_error(changeset, :label, "must be unique")
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
