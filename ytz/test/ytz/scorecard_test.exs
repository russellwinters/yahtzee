defmodule Ytz.ScorecardTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.{Dice, Scorecard, Scoring}

  describe "new/0" do
    test "returns a new scorecard with all categories nil" do
      scorecard = Scorecard.new()

      assert %Scorecard{
               ones: nil,
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
             } = scorecard
    end
  end

  describe "score_category/3" do
    test "adds provided points to the specified category" do
      scorecard = Scorecard.new()
      updated_scorecard = Scorecard.score_category(scorecard, :ones, 3)
      assert updated_scorecard.ones == 3
      assert true
    end

    test "affects only specified category" do
      scorecard = Scorecard.new()
      updated_scorecard = Scorecard.score_category(scorecard, :fours, 12)

      for category <- Map.keys(Map.from_struct(scorecard)) do
        if category != :fours do
          assert Map.get(updated_scorecard, category) == nil
        end
      end

      assert true
    end

    test "returns error tuple with message for negatice int" do
      scorecard = Scorecard.new()
      result = Scorecard.score_category(scorecard, :sixes, -5)
      assert result == {:error, "Points cannot be negative"}
    end
  end

  describe "available_categories/1" do
    test "returns list of categories that are nil" do
      scorecard =
        Scorecard.new()
        |> Scorecard.score_category(:ones, 3)
        |> Scorecard.score_category(:full_house, 25)

      available = Scorecard.available_categories(scorecard)

      for category <- available do
        assert Map.get(scorecard, category) == nil
      end
    end

    test "excludes categories that have been scored" do
      scorecard =
        Scorecard.new()
        |> Scorecard.score_category(:ones, 3)
        |> Scorecard.score_category(:full_house, 25)

      available = Scorecard.available_categories(scorecard)

      refute :ones in available
      refute :full_house in available
    end
  end

  describe "available_categories/2" do
    test "returns only available categories that can be scored with given dice" do
      scorecard =
        Scorecard.new()
        |> Scorecard.score_category(:ones, 3)
        |> Scorecard.score_category(:full_house, 25)

      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      available = Scorecard.available_categories(scorecard, dice)

      assert :three_of_a_kind in available
      refute :full_house in available
      refute :ones in available
      refute :four_of_a_kind in available
      refute :small_straight in available
      refute :large_straight in available
      refute :yahtzee in available
    end

    test "returns error tuple when given invalid dice" do
      scorecard = Scorecard.new()
      result = Scorecard.available_categories(scorecard, :invalid_dice)
      assert result == {:error, "Invalid dice provided"}
    end
  end

  describe "calculate_score/2" do
    test "returns error tuple when given invalid dice" do
      result = Scorecard.calculate_score(:ones, :invalid_dice)
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

      result = Scorecard.calculate_score(:invalid_category, init_dice)
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

      assert Scorecard.calculate_score(:three_of_a_kind, init_dice) ==
               Scoring.calculate_three_of_a_kind(init_dice)

      assert Scorecard.calculate_score(:four_of_a_kind, init_dice) ==
               Scoring.calculate_four_of_a_kind(init_dice)

      assert Scorecard.calculate_score(:full_house, full_house_dice) ==
               Scoring.calculate_full_house(full_house_dice)

      assert Scorecard.calculate_score(:small_straight, full_house_dice) ==
               Scoring.calculate_small_straight(full_house_dice)

      assert Scorecard.calculate_score(:large_straight, large_straight_dice) ==
               Scoring.calculate_large_straight(large_straight_dice)

      assert Scorecard.calculate_score(:yahtzee, init_dice) ==
               Scoring.calculate_yahtzee(init_dice)

      assert Scorecard.calculate_score(:chance, full_house_dice) ==
               Scoring.sum_dice_values(full_house_dice)
    end
  end
end
