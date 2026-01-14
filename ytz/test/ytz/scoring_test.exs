defmodule Ytz.ScoringTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.{Dice, Scorecard, Scoring}
end

defmodule Ytz.ScoringCalculationTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.Scoring

  describe "three_of_a_kind/1" do
    test "returns sum of dice when three of a kind present" do
      dice = [
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 4, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_three_of_a_kind(dice) == 16
    end

    test "returns sum of dice when more than three of a kind present" do
      dice = [
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_three_of_a_kind(dice) == 14
    end

    test "returns 0 when not three of a kind" do
      dice = [
        %{value: 1, frozen: false},
        %{value: 2, frozen: false},
        %{value: 3, frozen: false},
        %{value: 4, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_three_of_a_kind(dice) == 0
    end
  end

  describe "four_of_a_kind/1" do
    test "returns sum of dice when four of a kind present" do
      dice = [
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 2, frozen: false}
      ]

      assert Scoring.calculate_four_of_a_kind(dice) == 22
    end

    test "returns sum of dice when more than four of a kind present" do
      dice = [
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 5, frozen: false}
      ]

      assert Scoring.calculate_four_of_a_kind(dice) == 25
    end

    test "returns 0 when not four of a kind" do
      dice = [
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 5, frozen: false},
        %{value: 4, frozen: false},
        %{value: 2, frozen: false}
      ]

      assert Scoring.calculate_four_of_a_kind(dice) == 0
    end
  end

  describe "full_house/1" do
    test "returns 25 for a full house" do
      dice = [
        %{value: 3, frozen: false},
        %{value: 3, frozen: false},
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 3, frozen: false}
      ]

      assert Scoring.calculate_full_house(dice) == 25
    end

    test "returns 0 when not a full house" do
      dice = [
        %{value: 3, frozen: false},
        %{value: 3, frozen: false},
        %{value: 3, frozen: false},
        %{value: 3, frozen: false},
        %{value: 3, frozen: false}
      ]

      assert Scoring.calculate_full_house(dice) == 0
    end
  end

  describe "small_straight/1" do
    test "returns 30 when small straight present" do
      dice = [
        %{value: 1, frozen: false},
        %{value: 2, frozen: false},
        %{value: 3, frozen: false},
        %{value: 4, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_small_straight(dice) == 30
    end

    test "returns 30 when large straight present" do
      dice = [
        %{value: 1, frozen: false},
        %{value: 2, frozen: false},
        %{value: 3, frozen: false},
        %{value: 4, frozen: false},
        %{value: 5, frozen: false}
      ]

      assert Scoring.calculate_small_straight(dice) == 30
    end

    test "returns 0 when not small straight" do
      dice = [
        %{value: 1, frozen: false},
        %{value: 2, frozen: false},
        %{value: 2, frozen: false},
        %{value: 4, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_small_straight(dice) == 0
    end
  end

  describe "large_straight/1" do
    test "returns 40 when large straight present" do
      dice = [
        %{value: 2, frozen: false},
        %{value: 3, frozen: false},
        %{value: 4, frozen: false},
        %{value: 5, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_large_straight(dice) == 40
    end

    test "returns 0 when not large straight" do
      dice = [
        %{value: 1, frozen: false},
        %{value: 2, frozen: false},
        %{value: 3, frozen: false},
        %{value: 5, frozen: false},
        %{value: 6, frozen: false}
      ]

      assert Scoring.calculate_large_straight(dice) == 0
    end
  end

  describe "yahtzee/1" do
    test "returns 50 when all dice same" do
      dice = [
        %{value: 4, frozen: false},
        %{value: 4, frozen: false},
        %{value: 4, frozen: false},
        %{value: 4, frozen: false},
        %{value: 4, frozen: false}
      ]

      assert Scoring.calculate_yahtzee(dice) == 50
    end

    test "returns 0 when not yahtzee" do
      dice = [
        %{value: 4, frozen: false},
        %{value: 4, frozen: false},
        %{value: 4, frozen: false},
        %{value: 4, frozen: false},
        %{value: 3, frozen: false}
      ]

      assert Scoring.calculate_yahtzee(dice) == 0
    end
  end
end
