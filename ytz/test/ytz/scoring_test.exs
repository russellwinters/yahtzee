defmodule Ytz.ScoringTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.{Dice, Scoring}

  describe "calculate_score/2" do
    test "returns error tuple when given invalid dice" do
      result = Scoring.calculate_score(:ones, :invalid_dice)
      assert result == {:error, "Invalid dice provided"}
    end

    test "returns error tuple when given invalid category" do
      init_dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false}
        ]
      }

      result = Scoring.calculate_score(:invalid_category, init_dice)
      assert result == {:error, "Invalid category"}
    end

    test "match statement returns value from appropriate scoring module function" do
      init_dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false}
        ]
      }

      large_straight_dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      full_house_dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      assert Scoring.calculate_score(:three_of_a_kind, init_dice) == 5
      assert Scoring.calculate_score(:four_of_a_kind, init_dice) == 5
      assert Scoring.calculate_score(:full_house, full_house_dice) == 25
      assert Scoring.calculate_score(:small_straight, full_house_dice) == 0
      assert Scoring.calculate_score(:large_straight, large_straight_dice) == 40
      assert Scoring.calculate_score(:yahtzee, init_dice) == 50
      assert Scoring.calculate_score(:chance, full_house_dice) == 13
    end
  end

  describe "sum_dice_values/1" do
    test "returns sum of all dice values" do
      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.sum_dice_values(dice) == 20
    end

    test "returns error when non-Dice struct provided" do
      assert Scoring.sum_dice_values(:bad) == {:error, "Dice struct must be passed"}
    end
  end

  describe "sum_dice_values/2" do
    test "returns sum of dice matching the given value" do
      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 2, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.sum_dice_values(dice, 2) == 4
    end

    test "returns 0 when no dice match the given value" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.sum_dice_values(dice, 2) == 0
    end

    test "returns error when non-Dice struct provided" do
      assert Scoring.sum_dice_values(:bad, 2) == {:error, "Dice struct must be passed"}
    end

    test "returns error when int isnt provided for match" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.sum_dice_values(dice, :bad) == {:error, "Match must be an integer"}
    end
  end

  describe "valid_for_category?/2" do
    setup do
      init_dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false},
          %{value: 1, frozen: false}
        ]
      }

      large_straight_dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      full_house_dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      %{
        init_dice: init_dice,
        large_straight_dice: large_straight_dice,
        full_house_dice: full_house_dice
      }
    end

    test "always returns true for upper section and chance categories", %{
      init_dice: init_dice,
      large_straight_dice: large_straight_dice,
      full_house_dice: full_house_dice
    } do
      for category <- [:ones, :twos, :threes, :fours, :fives, :sixes, :chance] do
        assert Scoring.valid_for_category?(init_dice, category)
        assert Scoring.valid_for_category?(large_straight_dice, category)
        assert Scoring.valid_for_category?(full_house_dice, category)
      end
    end

    test "three_of_a_kind detection", %{
      full_house_dice: full_house_dice,
      large_straight_dice: large_straight_dice
    } do
      assert Scoring.valid_for_category?(full_house_dice, :three_of_a_kind)
      refute Scoring.valid_for_category?(large_straight_dice, :three_of_a_kind)
    end

    test "four_of_a_kind detection", %{
      init_dice: init_dice,
      large_straight_dice: large_straight_dice,
      full_house_dice: full_house_dice
    } do
      assert Scoring.valid_for_category?(init_dice, :four_of_a_kind)
      refute Scoring.valid_for_category?(large_straight_dice, :four_of_a_kind)
      refute Scoring.valid_for_category?(full_house_dice, :four_of_a_kind)
    end

    test "full_house detection", %{
      init_dice: init_dice,
      large_straight_dice: large_straight_dice,
      full_house_dice: full_house_dice
    } do
      assert Scoring.valid_for_category?(full_house_dice, :full_house)
      refute Scoring.valid_for_category?(init_dice, :full_house)
      refute Scoring.valid_for_category?(large_straight_dice, :full_house)
    end

    test "straight detection (small and large straight)", %{
      init_dice: init_dice,
      large_straight_dice: large_straight_dice
    } do
      assert Scoring.valid_for_category?(large_straight_dice, :small_straight)
      assert Scoring.valid_for_category?(large_straight_dice, :large_straight)
      refute Scoring.valid_for_category?(init_dice, :small_straight)
      refute Scoring.valid_for_category?(init_dice, :large_straight)
    end

    test "yahtzee detection", %{
      init_dice: init_dice,
      large_straight_dice: large_straight_dice,
      full_house_dice: full_house_dice
    } do
      assert Scoring.valid_for_category?(init_dice, :yahtzee)
      refute Scoring.valid_for_category?(large_straight_dice, :yahtzee)
      refute Scoring.valid_for_category?(full_house_dice, :yahtzee)
    end

    test "valid_for_category?/2 returns dice error for non-`Dice`" do
      assert Scoring.valid_for_category?(:bad, :ones) == {:error, "Dice struct must be passed"}
    end

    test "returns unknown category when dice is valid but category is invalid" do
      dice_struct = %Dice{}

      assert Scoring.valid_for_category?(dice_struct, :not_a_category) ==
               {:error, "Not a valid category :not_a_category"}
    end
  end
end
