defmodule GdCollabManager.CollabTools.ToDo.NewToDoItem do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :due_day, :string
    field :due_month, :string
    field :due_year, :string
    field :due_date, :utc_datetime
    field :tags, :string
  end

  def new do
    today = Date.utc_today()

    %__MODULE__{
      due_day: today.day,
      due_month: "#{today.month}",
      due_year: today.year,
      due_date: today,
      tags: "[]"
    }
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :due_day, :due_month, :due_year, :tags])
    |> validate_required([:title, :tags])
    |> validate_length(:title, min: 1, max: 100)
    |> validate_due_date()
    |> validate_tags()
  end

  def validate_tags(changeset) do
    case changeset do
      %{changes: %{tags: tags}} ->
        case tags
             |> Jason.decode!()
             |> Enum.all?(&is_integer/1) do
          true -> changeset
          false -> raise "Tags must be a list of integers"
        end

      _ ->
        changeset
    end
  end

  def validate_due_date(
        %{changes: %{due_day: due_day, due_month: due_month, due_year: due_year}} = changeset
      ) do
    case form_date(due_day, due_month, due_year) |> Date.from_iso8601() do
      {:ok, date} ->
        case Date.compare(date, Date.utc_today()) do
          :lt -> add_error(changeset, :due_date, "Due date must be in the future")
          _ -> changeset |> put_change(:due_date, date)
        end

      {:error, _} ->
        add_error(changeset, :due_date, "Invalid due date (won't be assigned a due date)")
    end
  end

  def validate_due_date(changeset) do
    add_error(changeset, :due_date, "Invalid due date (won't be assigned a due date)")
  end

  defp form_date(due_day, due_month, due_year) do
    "#{due_year}-#{due_month |> String.pad_leading(2, "0")}-#{due_day |> String.pad_leading(2, "0")}"
  end
end
