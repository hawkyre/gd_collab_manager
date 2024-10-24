defmodule GdCollabManager.CollabTools.Parts.CollabPart do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder,
           only: [:label, :order, :status, :comments, :start_time, :end_time, :to_do_item]}
  schema "collab_parts" do
    field :label, :string
    field :status, :string
    field :comments, :string
    field :start_time, :integer
    field :end_time, :integer
    field :order, :integer

    belongs_to :collab, GdCollabManager.Collabs.Collab
    belongs_to :to_do_item, GdCollabManager.ToDo.ToDoItem

    timestamps(type: :utc_datetime)
  end

  def new do
    %__MODULE__{
      label: "",
      status: "open",
      comments: "",
      start_time: 0,
      end_time: 0,
      order: -1
    }
  end

  @doc false
  def changeset(collab_part, attrs) do
    collab_part
    |> cast(attrs, [:start_time, :end_time, :label, :comments, :status, :collab_id, :order])
    |> validate_required([:start_time, :end_time, :label, :status, :order])
    |> validate_number(:start_time, greater_than_or_equal_to: 0)
    |> validate_number(:end_time, greater_than_or_equal_to: 0)
    |> validate_number(:start_time, less_than_or_equal_to: Map.get(attrs, :end_time, 0))
    |> validate_length(:label, max: 100)
    |> validate_length(:comments, max: 1000)
    |> cast_assoc(:to_do_item)
  end
end
