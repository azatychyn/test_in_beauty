defmodule History do
  def grep(term) do
    load_history()
    |> Stream.filter(&String.match?(&1, ~r/#{term}/))
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Enum.each(fn {value, index} ->
      IO.write("#{index}  ")
      IO.write(String.replace(value, term, "#{IO.ANSI.red()}#{term}#{IO.ANSI.default_color()}"))
    end)
  end
  def grep do
    load_history()
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Enum.each(fn {value, index} ->
      IO.write("#{index}  #{value}")
    end)
  end
  defp load_history, do: :group_history.load() |> Stream.map(&List.to_string/1)
end
