defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    Enum.sort_by(inventory, fn item -> item.price end)
  end

  def with_missing_price(inventory) do
    Enum.filter(inventory, fn item -> !item[:price] end)
  end

  def update_names(inventory, old_word, new_word) do
    Enum.map(inventory, &%{&1 | name: String.replace(&1.name, old_word, new_word)})
  end

  def increase_quantity(item, count) do
    %{item | quantity_by_size: increase_quantity_by_size(item.quantity_by_size, count)}
  end

  defp increase_quantity_by_size(quantity_by_size, quantity) do
    Map.new(quantity_by_size, fn {k, v} -> {k, v + quantity} end)
  end

  def total_quantity(item) do
    Enum.reduce(item.quantity_by_size, 0, fn {_k, v}, acc -> acc + v end)
  end
end
