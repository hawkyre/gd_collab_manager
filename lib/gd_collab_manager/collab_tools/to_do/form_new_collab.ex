defmodule GdCollabManager.CollabTools.ToDo.NewCollab do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :description, :string
    field :users, :string
  end

  def new do
    %__MODULE__{
      name: "",
      description: "",
      users: "[]"
    }
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :users])
    |> validate_required([:name, :users])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_users()
  end

  def validate_users(changeset) do
    case changeset do
      %{changes: %{tags: tags}} ->
        case tags
             |> Jason.decode!()
             |> Enum.all?(&is_integer/1) do
          true -> changeset
          false -> raise "Users must be a list of integers"
        end

      _ ->
        changeset
    end
  end
end
