defmodule GdCollabManager.Repo.Migrations.Collabs do
  use Ecto.Migration

  def change do
    create table(:collabs) do
      add :name, :string
      add :description, :string
      add :image_url, :string

      timestamps()
    end

    create table(:collab_participants) do
      add :role, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :collab_id, references(:collabs, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:collab_participants, [:user_id, :collab_id])
  end
end
