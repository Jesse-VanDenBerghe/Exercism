defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t(), [String.t()]) :: [String.t()]
  def match(base, candidates) do
    cased_base = String.upcase(base) |> String.to_charlist()

    Enum.filter(candidates, fn candidate ->
      cased_candidate = String.upcase(candidate) |> String.to_charlist()
      cased_base != cased_candidate and is_anagram(cased_base, cased_candidate)
    end)
  end

  defp is_anagram([], []), do: true
  defp is_anagram([], _), do: false
  defp is_anagram(_, []), do: false

  defp is_anagram(base, [h | t]) do
    if h in base do
      remaining = List.delete(base, h)
      is_anagram(remaining, t)
    else
      false
    end
  end
end
