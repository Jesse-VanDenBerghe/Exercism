defmodule BasketballWebsite do
  def extract_from_path(data, path) do
    [key | path_tail] = String.split(path, ".", parts: 2)
    data_point = data[key]

    cond do
      path_tail == [] -> data_point
      is_map(data_point) -> extract_from_path(data_point, List.first(path_tail))
      true -> nil
    end
  end

  def get_in_path(data, path) do
    Kernel.get_in(data, String.split(path, "."))
  end
end
