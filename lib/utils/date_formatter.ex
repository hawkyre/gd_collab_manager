defmodule Utils.DateFormatter do
  def format_date(nil), do: nil

  def format_date(date) do
    date
    |> NaiveDateTime.to_date()
    |> Calendar.strftime("%B %d, %Y")
  end
end
