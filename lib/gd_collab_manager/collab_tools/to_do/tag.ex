defmodule GdCollabManager.ToDo.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder, only: [:tag]}
  schema "tags" do
    field :tag, :string
    belongs_to :collab, GdCollabManager.Collabs.Collab
  end

  def new do
    %__MODULE__{}
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:tag, :collab_id])
    |> validate_required([:tag, :collab_id])
    |> unique_constraint([:tag, :collab_id])
  end
end
