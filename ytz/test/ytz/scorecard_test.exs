defmodule Ytz.ScorecardTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.{Dice, Scorecard}

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

  describe "available_categories/1" do
    test "returns list of categories that are nil" do
      scorecard =
        Scorecard.new()
        |> Scorecard.upsert_score(:ones, 3)
        |> Scorecard.upsert_score(:full_house, 25)

      available = Scorecard.available_categories(scorecard)

      for category <- available do
        assert Map.get(scorecard, category) == nil
      end
    end

    test "excludes categories that have been scored" do
      scorecard =
        Scorecard.new()
        |> Scorecard.upsert_score(:ones, 3)
        |> Scorecard.upsert_score(:full_house, 25)

      available = Scorecard.available_categories(scorecard)

      refute :ones in available
      refute :full_house in available
    end

    test "returns error tuple when given invalid scorecard" do
      result = Scorecard.available_categories(:invalid_scorecard)
      assert result == {:error, "Invalid scorecard provided"}
    end
  end

  describe "available_categories/2" do
    test "returns only available categories that can be scored with given dice" do
      scorecard =
        Scorecard.new()
        |> Scorecard.upsert_score(:ones, 3)
        |> Scorecard.upsert_score(:full_house, 25)

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

    test "returns error tuple when given invalid scorecard" do
      dice = %Dice{
        dice: [
          %{value: 2, frozen: false},
          %{value: 2, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false},
          %{value: 3, frozen: false}
        ]
      }

      result = Scorecard.available_categories(:invalid_scorecard, dice)
      assert result == {:error, "Invalid scorecard provided"}
    end

    test "returns error tuple if both dice and scorecard are invalid" do
      result = Scorecard.available_categories(:invalid_scorecard, :invalid_dice)
      assert result == {:error, "Invalid scorecard and dice provided"}
    end
  end

  describe "categories/0" do
    test "returns list of all valid categories" do
      categories = Scorecard.categories()

      expected_categories = [
        :ones,
        :twos,
        :threes,
        :fours,
        :fives,
        :sixes,
        :three_of_a_kind,
        :four_of_a_kind,
        :full_house,
        :small_straight,
        :large_straight,
        :yahtzee,
        :chance
      ]

      assert Enum.sort(categories) == Enum.sort(expected_categories)
    end
  end

  describe "upsert_score/3" do
    test "adds provided points to the specified category" do
      scorecard = Scorecard.new() |> Scorecard.upsert_score(:ones, 3)
      assert scorecard.ones == 3
    end

    test "affects only specified category" do
      scorecard = Scorecard.new() |> Scorecard.upsert_score(:fours, 12)

      for category <- Map.keys(Map.from_struct(scorecard)) do
        if category != :fours do
          assert Map.get(scorecard, category) == nil
        end
      end
    end

    test "returns error tuple when points are negative" do
      scorecard = Scorecard.new() |> Scorecard.upsert_score(:sixes, -5)
      assert scorecard == {:error, "Points cannot be negative"}
    end

    test "returns error tuple with message for invalid category" do
      scorecard = Scorecard.new() |> Scorecard.upsert_score(:invalid_category, 10)
      assert scorecard == {:error, "Invalid category"}
    end

    test "returns error tuple with message for invalid scorecard" do
      scorecard = :invalid_scorecard |> Scorecard.upsert_score(:ones, 5)
      assert scorecard == {:error, "Invalid scorecard provided"}
    end
  end
end
