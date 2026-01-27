defmodule ArmstrongNumber do
  @moduledoc """
  Provides a way to validate whether or not a number is an Armstrong number
  """

  @spec valid?(integer) :: boolean
  def valid?(number) do
    digits = Integer.digits(number)
    length = length(digits)

    digits
    |> Enum.map(fn digit -> Integer.pow(digit, length) end)
    |> Enum.sum()
    |> Kernel.==(number)
  end
end
