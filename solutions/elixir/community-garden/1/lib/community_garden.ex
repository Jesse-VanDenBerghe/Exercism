# Use the Plot struct as it is provided
defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start(opts \\ []) do
    Agent.start(fn -> %{next_id: 1, plots: []} end, opts)
  end

  def list_registrations(pid) do
    Agent.get(pid, fn state -> state.plots end)
  end

  def register(pid, register_to) do
    Agent.get_and_update(pid, fn state ->
      plot_id = state.next_id

      new_plot = %Plot{plot_id: plot_id, registered_to: register_to}
      {new_plot, %{next_id: state.next_id + 1, plots: [new_plot | state.plots]}}
    end)
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn state ->
      filtered_plots = Enum.filter(state.plots, fn plot -> plot.plot_id != plot_id end)
      %{state | plots: filtered_plots}
    end)
  end

  def get_registration(pid, plot_id) do
    plot =
      Agent.get(pid, fn state ->
        Enum.find(state.plots, fn plot -> plot.plot_id == plot_id end)
      end)

    case plot do
      nil -> {:not_found, "plot is unregistered"}
      _ -> plot
    end
  end
end
