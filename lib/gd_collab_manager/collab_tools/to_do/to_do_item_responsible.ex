defmodule GdCollabManager.ToDo.ToDoItemResponsible do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "to_do_item_responsibles" do
    belongs_to :to_do_item, GdCollabManager.ToDo.ToDoItem
    belongs_to :user, GdCollabManager.Collabs.User
    belongs_to :collab, GdCollabManager.Collabs.Collab
  end

  def changeset(to_do_item_responsible, attrs) do
    to_do_item_responsible
    |> cast(attrs, [:user_id, :collab_id])
    |> validate_required([:user_id, :collab_id])
  end
end
