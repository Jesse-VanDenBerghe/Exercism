defmodule Bowling do
  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  defmodule Frame do
    defstruct rolls: [], tenth?: false

    def roll(%Frame{} = frame, value) do
      cond do
        completed?(frame) ->
          {:already_completed, frame}

        value < 0 ->
          {:error, "Negative roll is invalid"}

        value > 10 ->
          {:error, "Pin count exceeds pins on the lane"}

        invalid_sum?(frame, value) ->
          {:error, "Pin count exceeds pins on the lane"}

        true ->
          {:ok, %Frame{frame | rolls: frame.rolls ++ [value]}}
      end
    end

    defp invalid_sum?(%Frame{tenth?: false, rolls: rolls}, value) do
      Enum.sum(rolls) + value > 10
    end

    defp invalid_sum?(%Frame{tenth?: true, rolls: [r1]}, value) when r1 < 10 do
      r1 + value > 10
    end

    defp invalid_sum?(%Frame{tenth?: true, rolls: [10, r2]}, value) when r2 < 10 do
      r2 + value > 10
    end

    defp invalid_sum?(_, _), do: false

    def completed?(%Frame{rolls: rolls, tenth?: false}) do
      length(rolls) == 2 or Enum.sum(rolls) == 10
    end

    def completed?(%Frame{rolls: rolls, tenth?: true}) do
      cond do
        length(rolls) < 2 -> false
        length(rolls) == 2 and Enum.sum(rolls) < 10 -> true
        length(rolls) == 3 -> true
        true -> false
      end
    end
  end

  defmodule Game do
    defstruct frames: [], current_frame: 0

    def completed?(%Game{frames: frames}) do
      length(frames) == 10 and Enum.all?(frames, &Frame.completed?/1)
    end

    def roll(%Game{frames: frames, current_frame: current_frame} = game, value) do
      cond do
        value < 0 ->
          {:error, "Negative roll is invalid"}

        value > 10 ->
          {:error, "Pin count exceeds pins on the lane"}

        completed?(game) ->
          {:error, "Cannot roll after game is over"}

        true ->
          frame_index = min(current_frame, 9)
          frame = Enum.at(frames, frame_index, %Frame{tenth?: frame_index == 9})

          case Frame.roll(frame, value) do
            {:already_completed, _} ->
              {:error, "Cannot roll after game is over"}

            {:error, reason} ->
              {:error, reason}

            {:ok, updated_frame} ->
              updated_frames =
                if frame_index < length(frames) do
                  List.replace_at(frames, frame_index, updated_frame)
                else
                  frames ++ [updated_frame]
                end

              new_current_frame =
                if Frame.completed?(updated_frame) and frame_index < 9 do
                  current_frame + 1
                else
                  current_frame
                end

              {:ok, %Game{frames: updated_frames, current_frame: new_current_frame}}
          end
      end
    end

    def score(%Game{frames: frames} = game) do
      if completed?(game) do
        total_score = calculate_score(frames)
        {:ok, total_score}
      else
        {:error, "Score cannot be taken until the end of the game"}
      end
    end

    defp calculate_score(frames) do
      Enum.reduce(0..9, 0, fn frame_index, acc ->
        acc + frame_score(frames, frame_index)
      end)
    end

    defp frame_score(frames, frame_index) do
      frame = Enum.at(frames, frame_index)
      rolls = frame.rolls

      cond do
        Enum.sum(rolls) < 10 ->
          Enum.sum(rolls)

        length(rolls) == 1 and Enum.at(rolls, 0) == 10 ->
          bonus = strike_bonus(frames, frame_index)
          10 + bonus

        length(rolls) == 2 and Enum.sum(rolls) == 10 ->
          bonus = spare_bonus(frames, frame_index)
          10 + bonus

        true ->
          Enum.sum(rolls)
      end
    end

    defp strike_bonus(frames, frame_index) do
      next_rolls = get_next_rolls(frames, frame_index, 2)
      Enum.sum(next_rolls)
    end

    defp spare_bonus(frames, frame_index) do
      next_rolls = get_next_rolls(frames, frame_index, 1)
      Enum.sum(next_rolls)
    end

    defp get_next_rolls(frames, frame_index, count) do
      rolls = []

      Enum.reduce_while((frame_index + 1)..9, rolls, fn idx, acc ->
        frame = Enum.at(frames, idx)

        Enum.reduce_while(frame.rolls, acc, fn roll, acc2 ->
          if length(acc2) < count do
            {:cont, acc2 ++ [roll]}
          else
            {:halt, acc2}
          end
        end)
        |> case do
          acc3 when length(acc3) >= count -> {:halt, acc3}
          acc3 -> {:cont, acc3}
        end
      end)
      |> Enum.take(count)
    end
  end

  @spec start() :: any
  def start do
    %Game{}
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful error tuple.
  """

  @spec roll(any, integer) :: {:ok, any} | {:error, String.t()}
  def roll(game, roll) do
    Game.roll(game, roll)
  end

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful error tuple.
  """

  @spec score(any) :: {:ok, integer} | {:error, String.t()}
  def score(game) do
    Game.score(game)
  end
end
