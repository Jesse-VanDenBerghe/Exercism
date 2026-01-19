defmodule HighScore do
  def new(), do: %{}

  def add_player(scores, name, score \\ 0)

  def add_player(scores, name, score) do
    Map.put(scores, name, score)
  end

  def remove_player(scores, name) do
    Map.delete(scores, name)
  end

  def reset_score(scores, name) do
    add_player(scores, name)
  end

  def update_score(scores, name, score) do
    previous_score = Map.get(scores, name, 0)
    Map.put(scores, name, previous_score + score)
  end

  def get_players(scores) do
    Map.keys(scores)
  end
end
