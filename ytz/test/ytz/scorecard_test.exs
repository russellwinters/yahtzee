defmodule Ytz.ScorecardTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.Scorecard

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
end
