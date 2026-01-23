defmodule TopSecret do
  def to_ast(string) do
    Code.string_to_quoted!(string)
  end

  def decode_secret_message_part(ast, acc) do
    case ast do
      {:defp, _, [function, _]} ->
        {ast, [function_to_arity_string(function) | acc]}

      {:def, _, [function, _]} ->
        {ast, [function_to_arity_string(function) | acc]}

      _ ->
        {ast, acc}
    end
  end

  defp function_to_arity_string({:when, _, [function, _guard]}) do
    # There seems to be an edge case where, on a guard case, it is evaluated with :when first instead of the actual function
    function_to_arity_string(function)
  end

  defp function_to_arity_string({name, _, args}) when is_list(args) do
    name
    |> Atom.to_string()
    |> String.slice(0, length(args))
  end

  defp function_to_arity_string(_), do: ""

  def decode_secret_message(string) do
    ast = to_ast(string)

    {_ast, acc} = Macro.prewalk(ast, [], &decode_secret_message_part/2)

    inspect(acc)

    acc |> Enum.reverse() |> Enum.join()
  end
end
