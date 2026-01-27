defmodule AllYourBase do
  @doc """
  Given a number in input base, represented as a sequence of digits, converts it to output base,
  or returns an error tuple if either of the bases are less than 2
  """

  @spec convert(list, integer, integer) :: {:ok, list} | {:error, String.t()}
  def convert(digits, input_base, output_base) do
    cond do
      input_base < 2 ->
        {:error, "input base must be >= 2"}

      output_base < 2 ->
        {:error, "output base must be >= 2"}

      Enum.any?(digits, &(&1 < 0 or &1 >= input_base)) ->
        {:error, "all digits must be >= 0 and < input base"}

      true ->
        decoded_int = decode(digits, input_base)
        inspect(decoded_int, label: "decoded: #{inspect(digits)} [#{input_base}]")
        {_, output_list} = encode(decoded_int, output_base)
        inspect(output_list, label: "encoded: #{inspect(decoded_int)} [#{output_base}]")
        {:ok, output_list}
    end
  end

  defp decode(digits, input_base, output_int \\ 0)

  defp decode([], _, output_int), do: output_int

  defp decode([digit | rest], input_base, output_int) do
    decoded_digit = digit * Integer.pow(input_base, length(rest))
    decode(rest, input_base, output_int + decoded_digit)
  end

  def encode(int, output_base, exponent \\ 0, output_list \\ [])

  def encode(0, _, _, _), do: {0, [0]}

  def encode(int, output_base, exponent, output_list) do
    divider = Integer.pow(output_base, exponent)

    if divider != 0 and div(int, divider) == 0 do
      {int, output_list}
    else
      {rest, list_to_append} = encode(int, output_base, exponent + 1, output_list)
      digit = div(rest, divider)
      rem = rem(rest, divider)
      {rem, list_to_append ++ [digit]}
    end
  end
end

AllYourBase.convert([2, 10], 16, 3)
