defmodule CollatzConjecture do
  require Integer

  @doc """
  calc/1 takes an integer and returns the number of steps required to get the
  number to 1 when following the rules:
    - if number is odd, multiply with 3 and add 1
    - if number is even, divide by 2
  """
  @spec calc(input :: pos_integer()) :: non_neg_integer()
  def calc(input, steps \\ 0)

  def calc(input, _) when input <= 0 do
    raise FunctionClauseError
  end

  def calc(1, steps), do: steps

  def calc(input, steps) when Integer.is_even(input), do: calc(div(input, 2), steps + 1)
  def calc(input, steps) when Integer.is_odd(input), do: calc(input * 3 + 1, steps + 1)
end
