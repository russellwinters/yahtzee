defmodule Ytz.ScoringTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.{Dice, Scorecard, Scoring}

  describe "calculate_three_of_a_kind/1" do
    @tag :focus
    test "returns sum of dice when three of a kind present" do
      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 4, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_three_of_a_kind(dice) == 16
    end

    test "returns sum of dice when more than three of a kind present" do
      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_three_of_a_kind(dice) == 14
    end

    test "returns 0 when not three of a kind" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_three_of_a_kind(dice) == 0
    end
  end

  describe "calculate_four_of_a_kind/1" do
    test "returns sum of dice when four of a kind present" do
      dice = %Dice{
        dice: [
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 2, frozen: false}
        ]
      }

      assert Scoring.calculate_four_of_a_kind(dice) == 22
    end

    test "returns sum of dice when more than four of a kind present" do
      dice = %Dice{
        dice: [
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 5, frozen: false}
        ]
      }

      assert Scoring.calculate_four_of_a_kind(dice) == 25
    end

    test "returns 0 when not four of a kind" do
      dice = %Dice{
        dice: [
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 5, frozen: false},
          %{value: 4, frozen: false},
          %{value: 2, frozen: false}
        ]
      }

      assert Scoring.calculate_four_of_a_kind(dice) == 0
    end
  end

  describe "calculate_full_house/1" do
    test "returns 25 for a full house" do
      dice = %Dice{
        dice: [
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      assert Scoring.calculate_full_house(dice) == 25
    end

    test "returns 0 when not a full house" do
      dice = %Dice{
        dice: [
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      assert Scoring.calculate_full_house(dice) == 0
    end
  end

  describe "calculate_small_straight/1" do
    test "returns 30 when small straight present" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_small_straight(dice) == 30
    end

    test "returns 30 when large straight present" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false}
        ]
      }

      assert Scoring.calculate_small_straight(dice) == 30
    end

    test "returns 0 when not small straight" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 4, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_small_straight(dice) == 0
    end
  end

  describe "calculate_large_straight/1" do
    test "returns 40 when large straight present" do
      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 4, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_large_straight(dice) == 40
    end

    test "returns 0 when not large straight" do
      dice = %Dice{
        dice: [
          %{value: 1, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 5, frozen: false},
          %{value: 6, frozen: false}
        ]
      }

      assert Scoring.calculate_large_straight(dice) == 0
    end
  end

  describe "calculate_yahtzee/1" do
    test "returns 50 when all dice same" do
      dice = %Dice{
        dice: [
          %{value: 4, frozen: false},
          %{value: 4, frozen: false},
          %{value: 4, frozen: false},
          %{value: 4, frozen: false},
          %{value: 4, frozen: false}
        ]
      }

      assert Scoring.calculate_yahtzee(dice) == 50
    end

    test "returns 0 when not yahtzee" do
      dice = %Dice{
        dice: [
          %{value: 4, frozen: false},
          %{value: 4, frozen: false},
          %{value: 4, frozen: false},
          %{value: 4, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      assert Scoring.calculate_yahtzee(dice) == 0
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

  describe "error handling" do
    test "calculate functions return dice error when non-`Dice` provided" do
      dice_error = {:error, "Dice struct must be passed"}

      assert Scoring.calculate_three_of_a_kind(:bad) == dice_error
      assert Scoring.calculate_four_of_a_kind(:bad) == dice_error
      assert Scoring.calculate_full_house(:bad) == dice_error
      assert Scoring.calculate_small_straight(:bad) == dice_error
      assert Scoring.calculate_large_straight(:bad) == dice_error
      assert Scoring.calculate_yahtzee(:bad) == dice_error
    end
  end
end
