defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t(), [String.t()]) :: [String.t()]
  def match(base, candidates) do
    cased_base = String.upcase(base) |> String.to_charlist()

    Enum.filter(candidates, fn candidate ->
      cased_candidate = String.upcase(candidate) |> String.to_charlist()
      cased_base != cased_candidate and anagram?(cased_base, cased_candidate)
    end)
  end

  defp anagram?([], []), do: true
  defp anagram?([], _), do: false
  defp anagram?(_, []), do: false

  defp anagram?(base, [h | t]) do
    if h in base do
      remaining = List.delete(base, h)
      anagram?(remaining, t)
    else
      false
    end
  end
end
