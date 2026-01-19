defmodule BirdCount do
  def today([]), do: nil

  def today([head | _tail]), do: head

  def increment_day_count([]), do: [1]

  def increment_day_count([today | rest]) do
    [today + 1 | rest]
  end

  def has_day_without_birds?([]), do: false

  def has_day_without_birds?([head | tail]) do
    head == 0 or has_day_without_birds?(tail)
  end

  def total([]), do: 0

  def total([head | tail]) do
    head + total(tail)
  end

  def busy_days([]), do: 0

  def busy_days([head | tail]) do
    if(head >= 5, do: 1, else: 0) + busy_days(tail)
  end
end
