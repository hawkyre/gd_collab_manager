defmodule GdCollabManager.Utils.DateUtils do
  @spec days_until_due(NaiveDateTime.t()) :: String.t()
  def days_until_due(date) do
    date
    |> NaiveDateTime.to_date()
    |> Date.diff(Date.utc_today())
    |> days_until_due_text()
  end

  def days_until_due_text(0), do: "today"
  def days_until_due_text(1), do: "tomorrow"
  def days_until_due_text(-1), do: "yesterday"
  def days_until_due_text(days) when days < 0, do: "#{days * -1} days ago"
  def days_until_due_text(days), do: "in #{days} days"

  def format_due_date(%{"due_day" => ""}), do: nil
  def format_due_date(%{"due_month" => ""}), do: nil
  def format_due_date(%{"due_year" => ""}), do: nil

  def format_due_date(%{"due_day" => day, "due_month" => month, "due_year" => year})
      when is_binary(day) and is_binary(month) and is_binary(year) do
    format_due_date(%{
      "due_day" => day |> String.to_integer(),
      "due_month" => month |> String.to_integer(),
      "due_year" => year |> String.to_integer()
    })
  end

  def format_due_date(%{"due_day" => day, "due_month" => month, "due_year" => year}) do
    case NaiveDateTime.new(year, month, day, 0, 0, 0) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  def format_due_date(_), do: nil

  def format_date(nil), do: nil

  def format_date(date) do
    date
    |> NaiveDateTime.to_date()
    |> Calendar.strftime("%B %d, %Y")
  end
end
