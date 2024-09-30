defmodule GdCollabManager.Collabs.Collab do
  alias GdCollabManager.Collabs.CollabParticipant
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder,
           only: [
             :name,
             :description,
             :image_url,
             :participants,
             :to_do_items,
             :inserted_at,
             :updated_at,
             :tags
           ]}
  schema "collabs" do
    field :name, :string
    field :description, :string
    field :image_url, :string
    has_many :collab_participants, CollabParticipant, on_delete: :delete_all
    has_many :to_do_items, GdCollabManager.ToDo.ToDoItem, on_delete: :delete_all
    has_many :tags, GdCollabManager.ToDo.Tag, on_delete: :delete_all

    many_to_many :participants, GdCollabManager.Accounts.User, join_through: CollabParticipant

    timestamps()
  end

  @spec new() :: %__MODULE__{}
  def new() do
    %__MODULE__{}
  end

  @doc false
  def changeset(collab, attrs) do
    collab
    |> cast(attrs, [:name, :description, :image_url])
    |> cast_assoc(:collab_participants, with: &CollabParticipant.changeset/2)
    |> validate_required([:name])
    |> validate_has_at_least_one_host()
  end

  def validate_has_at_least_one_host(collab) do
    case has_at_least_one_host?(collab) do
      true -> collab
      false -> add_error(collab, :collab_participants, "must have at least one host")
    end
  end

  defp has_at_least_one_host?(collab) do
    Enum.any?(collab.changes.collab_participants, fn participant ->
      participant.changes.role == "host"
    end)
  end
end
