defmodule GdCollabManager.Collabs.CollabParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  alias GdCollabManager.Collabs.Collab
  alias GdCollabManager.Accounts.User

  @derive {Jason.Encoder, only: [:role, :user]}
  schema "collab_participants" do
    field :role, :string
    belongs_to :collab, Collab
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(collab_participant, attrs) do
    collab_participant
    |> cast(attrs, [:role, :user_id])
    |> validate_required([:role, :user_id])
  end
end
