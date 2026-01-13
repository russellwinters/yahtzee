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

  # def score_category(scorecard, category, points) do
  # def calculate_score(category, Dice) do
  # def calculate_score(scorecard, category, Dice) do
  # def available_categories(scorecard) do
  # def available_categories(scorecard, Dice) do --> This will take current dice to determine possible categories
  # def category_filled?(scorecard, category) do
  # def upper_total(scorecard) do
  # def upper_bonus(scorecard) do -> 35 or 0 based on upper total
  # def lower_total(scorecard) do
  # def total_score(scorecard) do
end
