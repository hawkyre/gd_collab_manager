defmodule GdCollabManager.ToDo.ToDoItem do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder,
           only: [
             :title,
             :description,
             :due_by,
             :priority,
             :completed,
             :creator_id,
             :tags,
             :responsibles
           ]}
  schema "to_do_items" do
    field :title, :string
    field :description, :string
    field :due_by, :utc_datetime
    field :priority, :integer
    field :completed, :boolean, default: false

    belongs_to :creator, GdCollabManager.Collabs.CollabParticipant
    belongs_to :collab, GdCollabManager.Collabs.Collab

    has_many :to_do_item_tags, GdCollabManager.ToDo.ToDoItemTag
    many_to_many :tags, GdCollabManager.ToDo.Tag, join_through: GdCollabManager.ToDo.ToDoItemTag

    has_many :to_do_item_responsibles, GdCollabManager.ToDo.ToDoItemResponsible

    many_to_many :responsibles, GdCollabManager.Accounts.User,
      join_through: GdCollabManager.ToDo.ToDoItemResponsible

    has_one :collab_part, GdCollabManager.CollabTools.Parts.CollabPart

    timestamps()
  end

  def new() do
    %__MODULE__{}
  end

  def changeset(to_do_item, attrs) do
    to_do_item
    |> cast(attrs, [:title, :description, :creator_id, :collab_id, :due_by, :priority, :completed])
    |> validate_required([:title, :collab_id])
    |> cast_assoc(:to_do_item_tags, with: &GdCollabManager.ToDo.ToDoItemTag.changeset/2)
    |> cast_assoc(:to_do_item_responsibles,
      with: &GdCollabManager.ToDo.ToDoItemResponsible.changeset/2
    )
  end
end
