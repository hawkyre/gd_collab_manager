defmodule GdCollabManager.Utils.DurationUtils do
  def seconds_to_mm_ss(seconds) do
    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)

    "#{minutes}:#{String.pad_leading(Integer.to_string(seconds), 2, "0")}"
  end
end
