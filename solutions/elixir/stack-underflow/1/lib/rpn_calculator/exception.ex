defmodule RPNCalculator.Exception do
  defmodule DivisionByZeroError do
    defexception message: "division by zero occurred"
  end

  defmodule StackUnderflowError do
    @base_message "stack underflow occurred"
    defexception message: @base_message

    def exception(value) do
      case value do
        [] ->
          %StackUnderflowError{}

        context when is_binary(context) ->
          %StackUnderflowError{message: "#{@base_message}, context: #{context}"}

        _ ->
          %StackUnderflowError{}
      end
    end
  end

  def divide(stack) when length(stack) < 2, do: raise(StackUnderflowError, "when dividing")
  def divide([0 | _]), do: raise(DivisionByZeroError)
  def divide([divider, divident | _]), do: divident / divider
end
