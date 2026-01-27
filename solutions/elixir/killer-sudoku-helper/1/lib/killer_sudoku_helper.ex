defmodule KillerSudokuHelper do
  @doc """
  Return the possible combinations of `size` distinct numbers from 1-9 excluding `exclude` that sum up to `sum`.
  """
  @spec combinations(cage :: %{exclude: [integer], size: integer, sum: integer}) :: [[integer]]
  def combinations(cage) do
    numbers = Enum.to_list(1..9) -- cage.exclude
    find_combinations(numbers, cage.size, cage.sum)
  end

  defp find_combinations(_, 0, 0), do: [[]]
  defp find_combinations(_, 0, _), do: []
  defp find_combinations([], _, _), do: []

  defp find_combinations([h | t], size, sum) do
    with_h = for combo <- find_combinations(t, size - 1, sum - h), do: [h | combo]
    without_h = find_combinations(t, size, sum)
    with_h ++ without_h
  end
end
