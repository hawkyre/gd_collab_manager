defmodule GdCollabManager.Collabs.Collab.Info do
  alias GdCollabManager.Collabs.CollabParticipant
  use Ecto.Schema

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder,
           only: [
             :name,
             :description,
             :image_url,
             :participants,
             :inserted_at,
             :updated_at
           ]}
  schema "collabs" do
    field :name, :string
    field :description, :string
    field :image_url, :string

    has_many :collab_participants, CollabParticipant,
      on_delete: :delete_all,
      foreign_key: :collab_id

    many_to_many :participants, GdCollabManager.Accounts.User, join_through: CollabParticipant

    timestamps()
  end
end
