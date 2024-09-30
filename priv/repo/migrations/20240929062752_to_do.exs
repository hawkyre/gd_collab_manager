defmodule GdCollabManager.Repo.Migrations.ToDo do
  use Ecto.Migration

  def change do
    create table(:to_do_items) do
      add :title, :string, null: false
      add :description, :text
      add :creator_id, references(:users, on_delete: :nilify_all)
      add :collab_id, references(:collabs, on_delete: :delete_all), null: false
      add :due_by, :utc_datetime
      add :priority, :integer
      add :completed, :boolean, default: false, null: false
      timestamps()
    end

    create unique_index(:to_do_items, [:id, :collab_id])

    execute """
            ALTER TABLE to_do_items
            ADD CONSTRAINT to_do_items_collab_id_creator_id_fkey
            FOREIGN KEY (collab_id, creator_id)
            REFERENCES collab_participants(collab_id, user_id)
            ON DELETE SET NULL
            """,
            "DROP CONSTRAINT to_do_items_collab_id_creator_id_fkey"

    create table(:tags) do
      add :tag, :string, null: false
      add :collab_id, references(:collabs, on_delete: :delete_all), null: false
    end

    create unique_index(:tags, [:tag, :collab_id])

    create table(:to_do_item_tags) do
      add :to_do_item_id, references(:to_do_items, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
    end

    create unique_index(:to_do_item_tags, [:to_do_item_id, :tag_id])

    create table(:to_do_item_comments) do
      add :to_do_item_id, references(:to_do_items, on_delete: :delete_all), null: false
      add :comment, :text, null: false

      add :collab_participant_id, references(:collab_participants, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:to_do_item_responsibles) do
      add :to_do_item_id, references(:to_do_items, on_delete: :delete_all), null: false

      add :user_id, references(:users, on_delete: :nilify_all)

      add :collab_id,
          references(:collabs, on_delete: :delete_all),
          null: false,
          with: [to_do_item_id: :id]
    end

    execute """
            ALTER TABLE to_do_item_responsibles
            ADD CONSTRAINT to_do_item_responsibles_collab_id_user_id_fkey
            FOREIGN KEY (collab_id, user_id)
            REFERENCES collab_participants(collab_id, user_id)
            ON DELETE SET NULL
            """,
            "DROP CONSTRAINT to_do_item_responsibles_collab_id_user_id_fkey"
  end
end
