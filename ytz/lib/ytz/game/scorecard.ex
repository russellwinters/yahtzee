defmodule Ytz.Game.Scorecard do
  alias Ytz.Game.{Dice, Scoring}

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

  def available_categories(scorecard, %Dice{} = dice) do
    scorecard
    |> Map.from_struct()
    |> Enum.filter(fn {_category, points} -> points == nil end)
    |> Enum.filter(fn {category, _points} -> Scoring.valid_for_category?(dice, category) end)
    |> Enum.map(fn {category, _points} -> category end)
  end

  # TODO: add test
  def available_categories(_scorecard, _dice) do
    {:error, "Invalid dice provided"}
  end

  def score_category(_scorecard, _category, points) when points < 0 do
    {:error, "Points cannot be negative"}
  end

  def score_category(scorecard, category, points) do
    Map.put(scorecard, category, points)
  end

  # TODO: test this fn
  def calculate_score(category, %Dice{} = dice) do
    case category do
      :ones -> Scoring.sum_dice_values(dice, 1)
      :twos -> Scoring.sum_dice_values(dice, 2)
      :threes -> Scoring.sum_dice_values(dice, 3)
      :fours -> Scoring.sum_dice_values(dice, 4)
      :fives -> Scoring.sum_dice_values(dice, 5)
      :sixes -> Scoring.sum_dice_values(dice, 6)
      :three_of_a_kind -> Scoring.calculate_three_of_a_kind(dice)
      :four_of_a_kind -> Scoring.calculate_four_of_a_kind(dice)
      :full_house -> Scoring.calculate_full_house(dice)
      :small_straight -> Scoring.calculate_small_straight(dice)
      :large_straight -> Scoring.calculate_large_straight(dice)
      :yahtzee -> Scoring.calculate_yahtzee(dice)
      :chance -> Scoring.sum_dice_values(dice, :all)
      _ -> {:error, "Invalid category"}
    end
  end

  def calculate_score(scorecard, category, %Dice{} = dice) do
    scorecard
    |> available_categories(dice)
    |> case do
      {:error, _} = error ->
        error

      available ->
        if category in available do
          calculate_score(category, dice)
        else
          {:error, "Category already filled or invalid for current dice"}
        end
    end
  end

  # TODO: implement catefory_filled?/2 and test so I can then use it to simplify calculate_score/3
  # def category_filled?(scorecard, category) do
  # def upper_total(scorecard) do
  # def upper_bonus(scorecard) do -> 35 or 0 based on upper total
  # def lower_total(scorecard) do
  # def total_score(scorecard) do
end
