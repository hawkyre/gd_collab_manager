defmodule GdCollabManager.ToDo.ToDoItemComment do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder, only: [:comment, :collab_participant_id, :inserted_at]}
  schema "to_do_item_comments" do
    field :comment, :string
    belongs_to :to_do_item, GdCollabManager.ToDo.ToDoItem
    belongs_to :collab_participant, GdCollabManager.Collabs.CollabParticipant
    timestamps()
  end

  def changeset(to_do_item_comment, attrs) do
    to_do_item_comment
    |> cast(attrs, [:to_do_item_id, :comment, :creator_id])
    |> validate_required([:to_do_item_id, :comment])
  end
end
