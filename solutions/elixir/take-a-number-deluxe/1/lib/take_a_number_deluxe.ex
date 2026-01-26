defmodule TakeANumberDeluxe do
  # Client API
  use GenServer
  alias TakeANumberDeluxe.State

  @spec start_link(keyword()) :: {:ok, pid()} | {:error, atom()}
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @spec report_state(pid()) :: State.t()
  def report_state(machine) do
    GenServer.call(machine, :report_state)
  end

  @spec queue_new_number(pid()) :: {:ok, integer()} | {:error, atom()}
  def queue_new_number(machine) do
    GenServer.call(machine, :queue_new_number)
  end

  @spec serve_next_queued_number(pid(), integer() | nil) :: {:ok, integer()} | {:error, atom()}
  def serve_next_queued_number(machine, priority_number \\ nil) do
    GenServer.call(machine, {:serve_next_queued_number, priority_number})
  end

  @spec reset_state(pid()) :: :ok
  def reset_state(machine) do
    GenServer.cast(machine, :reset_state)
  end

  # Server callbacks

  @impl GenServer
  def init(init_arg) do
    min = Keyword.get(init_arg, :min_number)
    max = Keyword.get(init_arg, :max_number)
    timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

    case State.new(min, max, timeout) do
      {:ok, state} -> {:ok, state, timeout}
      {:error, error} -> {:stop, error}
    end
  end

  @impl GenServer
  def handle_call(:report_state, _from, %State{} = state) do
    {:reply, state, state, state.auto_shutdown_timeout}
  end

  @impl GenServer
  def handle_call(:queue_new_number, _from, %State{} = state) do
    State.queue_new_number(state)
    |> handle_state_result(state)
  end

  @impl GenServer
  def handle_call(
        {:serve_next_queued_number, priority},
        _from,
        %State{} = state
      ) do
    State.serve_next_queued_number(state, priority)
    |> handle_state_result(state)
  end

  @impl GenServer
  def handle_cast(:reset_state, %State{
        min_number: min,
        max_number: max,
        auto_shutdown_timeout: timeout
      }) do
    case State.new(min, max, timeout) do
      {:ok, new_state} -> {:noreply, new_state, timeout}
      {:error, error} -> {:stop, error}
    end
  end

  defp handle_state_result({:ok, result, new_state}, _old_state) do
    {:reply, {:ok, result}, new_state, new_state.auto_shutdown_timeout}
  end

  defp handle_state_result({:error, _} = error, state) do
    {:reply, error, state, state.auto_shutdown_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state, state.auto_shutdown_timeout}
  end
end
