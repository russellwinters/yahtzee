defmodule Ytz.Game.Scoring do
  alias Ytz.Game.Dice
  alias Ytz.Game.Scorecard

  @small_straights [
    [1, 2, 3, 4],
    [2, 3, 4, 5],
    [3, 4, 5, 6]
  ]
  @large_straights [
    [1, 2, 3, 4, 5],
    [2, 3, 4, 5, 6]
  ]

  def calculate_three_of_a_kind(dice) do
    if valid_for_category?(dice, :three_of_a_kind) do
      dice |> Enum.map(& &1.value) |> Enum.sum()
    else
      0
    end
  end

  def calculate_four_of_a_kind(dice) do
    if valid_for_category?(dice, :four_of_a_kind) do
      dice |> Enum.map(& &1.value) |> Enum.sum()
    else
      0
    end
  end

  def calculate_full_house(dice) do
    if valid_for_category?(dice, :full_house), do: 25, else: 0
  end

  def calculate_small_straight(dice) do
    if valid_for_category?(dice, :small_straight), do: 30, else: 0
  end

  def calculate_large_straight(dice) do
    if valid_for_category?(dice, :large_straight), do: 40, else: 0
  end

  def calculate_yahtzee(dice) do
    if valid_for_category?(dice, :yahtzee), do: 50, else: 0
  end

  defp valid_for_category?(_dice, category)
       when category in [:ones, :twos, :threes, :fours, :fives, :sixes, :chance] do
    true
  end

  defp valid_for_category?(dice, :three_of_a_kind) do
    has_n_of_a_kind?(dice, 3)
  end

  defp valid_for_category?(dice, :four_of_a_kind) do
    has_n_of_a_kind?(dice, 4)
  end

  defp valid_for_category?(dice, :full_house) do
    values = Enum.map(dice, fn die -> die.value end)
    counts = Enum.frequencies(values) |> Map.values() |> Enum.sort()
    counts == [2, 3]
  end

  defp valid_for_category?(dice, :small_straight) do
    values = Enum.map(dice, fn die -> die.value end) |> Enum.uniq() |> Enum.sort()

    Enum.any?(@small_straights, fn straight -> Enum.all?(straight, &(&1 in values)) end) or
      valid_for_category?(dice, :large_straight)
  end

  defp valid_for_category?(dice, :large_straight) do
    values = Enum.map(dice, fn die -> die.value end) |> Enum.uniq() |> Enum.sort()
    Enum.any?(@large_straights, fn straight -> straight == values end)
  end

  defp valid_for_category?(dice, :yahtzee) do
    values = Enum.map(dice, fn die -> die.value end)
    Enum.uniq(values) |> length() == 1
  end

  defp has_n_of_a_kind?(dice, n) do
    values = Enum.map(dice, fn die -> die.value end)
    counts = Enum.frequencies(values)
    Enum.any?(counts, fn {_value, count} -> count >= n end)
  end
end
