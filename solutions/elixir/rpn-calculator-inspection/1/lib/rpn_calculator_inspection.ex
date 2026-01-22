defmodule RPNCalculatorInspection do
  def start_reliability_check(calculator, input) do
    pid = spawn_link(fn -> calculator.(input) end)
    %{input: input, pid: pid}
  end

  def await_reliability_check_result(%{pid: pid, input: input}, results) do
    result_code =
      receive do
        {:EXIT, ^pid, :normal} -> :ok
        {:EXIT, ^pid, _} -> :error
      after
        100 -> :timeout
      end

    Map.put(results, input, result_code)
  end

  def reliability_check(calculator, inputs) do
    old = Process.flag(:trap_exit, true)

    results =
      Enum.map(inputs, &start_reliability_check(calculator, &1))
      |> Enum.reduce(%{}, &await_reliability_check_result/2)

    Process.flag(:trap_exit, old)

    results
  end

  def correctness_check(calculator, inputs) do
    Enum.map(inputs, &Task.async(fn -> calculator.(&1) end))
    |> Enum.map(&Task.await(&1, 100))
  end
end
