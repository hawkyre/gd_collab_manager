defmodule GdCollabManager.ToDo.ToDoItemTag do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  @derive {Jason.Encoder, only: [:tag]}
  schema "to_do_item_tags" do
    belongs_to :to_do_item, GdCollabManager.ToDo.ToDoItem
    belongs_to :tag, GdCollabManager.ToDo.Tag
  end

  def changeset(to_do_item_tag, attrs) do
    to_do_item_tag
    |> cast(attrs, [:tag_id])
    |> validate_required([:tag_id])
  end
end
