defmodule Ytz.Game.Scorecard do
  defstruct ones: nil,
            twos: nil,
            threes: nil,
            fours: nil,
            fives: nil,
            sixes: nil,
            three_of_a_kind: nil,
            four_of_a_kind: nil,
            full_house: nil,
            small_straight: nil,
            large_straight: nil,
            yahtzee: nil,
            chance: nil

  @type t :: %__MODULE__{
          ones: non_neg_integer() | nil,
          twos: non_neg_integer() | nil,
          threes: non_neg_integer() | nil,
          fours: non_neg_integer() | nil,
          fives: non_neg_integer() | nil,
          sixes: non_neg_integer() | nil,
          three_of_a_kind: non_neg_integer() | nil,
          four_of_a_kind: non_neg_integer() | nil,
          full_house: non_neg_integer() | nil,
          small_straight: non_neg_integer() | nil,
          large_straight: non_neg_integer() | nil,
          yahtzee: non_neg_integer() | nil,
          chance: non_neg_integer() | nil
        }

  def new do
    %__MODULE__{}
  end

  def available_categories(scorecard) do
    scorecard
    |> Map.from_struct()
    |> Enum.filter(fn {_category, points} -> points == nil end)
    |> Enum.map(fn {category, _points} -> category end)
  end

  # TODO: implement logic here, with scoring module
  def available_categories(scorecard, dice) do
    scorecard
    |> Map.from_struct()
    |> Enum.filter(fn {_category, points} -> points == nil end)
    |> Enum.filter(fn {category, _points} -> valid_for_category?(dice, category) end)
    |> Enum.map(fn {category, _points} -> category end)
  end

  def score_category(_scorecard, _category, points) when points < 0 do
    {:error, "Points cannot be negative"}
  end

  def score_category(scorecard, category, points) do
    Map.put(scorecard, category, points)
  end

  # def calculate_score(category, Dice) do
  # def calculate_score(scorecard, category, Dice) do
  # def category_filled?(scorecard, category) do
  # def upper_total(scorecard) do
  # def upper_bonus(scorecard) do -> 35 or 0 based on upper total
  # def lower_total(scorecard) do
  # def total_score(scorecard) do

  defp valid_for_category?(_dice, category)
       when category in [:ones, :twos, :threes, :fours, :fives, :sixes, :chance] do
    # TODO: implement validation logic for each category
    # Basically for top and chance, it's always valid
    # For others, need to check if dice meet the criteria
    true
  end

  defp valid_for_category?(_dice, category)
       when category in [:ones, :twos, :threes, :fours, :fives, :sixes, :chance] do
    # TODO: implement validation logic for each category
    # For others, need to check if dice meet the criteria
    true
  end

  # TODO: pull validation logic from each of these utils into separate util
  # TODO: pull all these utils into separate Scoring module

  defp has_n_of_a_kind?(dice, n) do
    values = Enum.map(dice, fn die -> die.value end)
    counts = Enum.frequencies(values)
    Enum.any?(counts, fn {_value, count} -> count >= n end)
  end

  defp calculate_three_of_a_kind(dice) do
    if has_n_of_a_kind?(dice, 3) do
      dice |> Enum.map(& &1.value) |> Enum.sum()
    else
      0
    end
  end

  defp calculate_four_of_a_kind(dice) do
    if has_n_of_a_kind?(dice, 4) do
      dice |> Enum.map(& &1.value) |> Enum.sum()
    else
      0
    end
  end

  defp calculate_full_house(dice) do
    values = Enum.map(dice, fn die -> die.value end)
    counts = Enum.frequencies(values) |> Map.values() |> Enum.sort()

    if counts == [2, 3] do
      25
    else
      0
    end
  end

  defp calculate_small_straight(dice) do
    values = Enum.map(dice, fn die -> die.value end) |> Enum.uniq() |> Enum.sort()
    straights = [[1, 2, 3, 4], [2, 3, 4, 5], [3, 4, 5, 6]]

    if Enum.any?(straights, fn straight -> Enum.all?(straight, &(&1 in values)) end) do
      30
    else
      0
    end
  end

  defp calculate_large_straight(dice) do
    values = Enum.map(dice, fn die -> die.value end) |> Enum.uniq() |> Enum.sort()
    straights = [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6]]

    if Enum.any?(straights, fn straight -> straight == values end) do
      40
    else
      0
    end
  end

  defp calculate_yahtzee(dice) do
    values = Enum.map(dice, fn die -> die.value end)

    if Enum.uniq(values) |> length() == 1 do
      50
    else
      0
    end
  end
end
