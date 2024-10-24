defmodule GdCollabManager.Repo.Migrations.CreateCollabParts do
  use Ecto.Migration

  def change do
    create table(:collab_parts) do
      add :start_time, :integer, null: false
      add :end_time, :integer, null: false
      add :label, :string
      add :comments, :string
      add :order, :integer, null: false
      add :status, :string, null: false, default: "open"
      add :to_do_item_id, references(:to_do_items, on_delete: :nilify_all)
      add :collab_id, references(:collabs, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:collab_parts, [:collab_id, :label])
  end
end
