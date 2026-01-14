defmodule Ytz.Game.Scoring do
  alias Ytz.Game.Dice

  @small_straights [
    [1, 2, 3, 4],
    [2, 3, 4, 5],
    [3, 4, 5, 6]
  ]
  @large_straights [
    [1, 2, 3, 4, 5],
    [2, 3, 4, 5, 6]
  ]
  @dice_error {:error, "Dice struct must be passed"}

  def sum_dice_values(%Dice{dice: dice_list}) do
    dice_list
    |> Enum.map(& &1.value)
    |> Enum.sum()
  end

  def sum_dice_values(_), do: @dice_error

  def sum_dice_values(%Dice{dice: dice_list}, match) when is_integer(match) do
    dice_list
    |> Enum.map(& &1.value)
    |> Enum.filter(fn value -> value == match end)
    |> Enum.sum()
  end

  def sum_dice_values(dice, _match) when not is_struct(dice, Dice), do: @dice_error

  def sum_dice_values(_dice, _match), do: {:error, "Match must be an integer"}

  def calculate_three_of_a_kind(%Dice{dice: dice_list} = dice) do
    if valid_for_category?(dice, :three_of_a_kind) do
      dice_list |> Enum.map(& &1.value) |> Enum.sum()
    else
      0
    end
  end

  def calculate_three_of_a_kind(_), do: @dice_error

  def calculate_four_of_a_kind(%Dice{dice: dice_list} = dice) do
    if valid_for_category?(dice, :four_of_a_kind) do
      dice_list |> Enum.map(& &1.value) |> Enum.sum()
    else
      0
    end
  end

  def calculate_four_of_a_kind(_), do: @dice_error

  def calculate_full_house(%Dice{dice: _dice_list} = dice) do
    if valid_for_category?(dice, :full_house), do: 25, else: 0
  end

  def calculate_full_house(_), do: @dice_error

  def calculate_small_straight(%Dice{dice: _dice_list} = dice) do
    if valid_for_category?(dice, :small_straight), do: 30, else: 0
  end

  def calculate_small_straight(_), do: @dice_error

  def calculate_large_straight(%Dice{dice: _dice_list} = dice) do
    if valid_for_category?(dice, :large_straight), do: 40, else: 0
  end

  def calculate_large_straight(_), do: @dice_error

  def calculate_yahtzee(%Dice{dice: _dice_list} = dice) do
    if valid_for_category?(dice, :yahtzee), do: 50, else: 0
  end

  def calculate_yahtzee(_), do: @dice_error

  def valid_for_category?(dice, _category) when not is_struct(dice, Dice) do
    @dice_error
  end

  def valid_for_category?(_dice, category)
      when category in [:ones, :twos, :threes, :fours, :fives, :sixes, :chance] do
    true
  end

  def valid_for_category?(%Dice{} = dice, :three_of_a_kind) do
    has_n_of_a_kind?(dice, 3)
  end

  def valid_for_category?(%Dice{} = dice, :four_of_a_kind) do
    has_n_of_a_kind?(dice, 4)
  end

  def valid_for_category?(%Dice{dice: dice_list}, :full_house) do
    values = Enum.map(dice_list, fn die -> die.value end)
    counts = Enum.frequencies(values) |> Map.values() |> Enum.sort()
    counts == [2, 3]
  end

  def valid_for_category?(%Dice{dice: dice_list} = dice, :small_straight) do
    values = Enum.map(dice_list, fn die -> die.value end) |> Enum.uniq() |> Enum.sort()

    Enum.any?(@small_straights, fn straight -> Enum.all?(straight, &(&1 in values)) end) or
      valid_for_category?(dice, :large_straight)
  end

  def valid_for_category?(%Dice{dice: dice_list}, :large_straight) do
    values = Enum.map(dice_list, fn die -> die.value end) |> Enum.uniq() |> Enum.sort()
    Enum.any?(@large_straights, fn straight -> straight == values end)
  end

  def valid_for_category?(%Dice{dice: dice_list}, :yahtzee) do
    values = Enum.map(dice_list, fn die -> die.value end)
    Enum.uniq(values) |> length() == 1
  end

  def valid_for_category?(_dice, category) do
    {:error, "Not a valid category #{inspect(category)}"}
  end

  defp has_n_of_a_kind?(%Dice{dice: dice_list}, n) do
    values = Enum.map(dice_list, fn die -> die.value end)
    counts = Enum.frequencies(values)
    Enum.any?(counts, fn {_value, count} -> count >= n end)
  end
end
