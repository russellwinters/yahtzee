defmodule Ytz.DiceTest do
  use ExUnit.Case, async: true

  alias Ytz.Game.Dice

  describe "new/0" do
    test "returns list of 5 dice" do
      dice = Dice.new()

      assert is_struct(dice, Dice)
      assert length(dice.dice) == 5
    end
  end

  describe "roll/1" do
    test "rolls only unfrozen dice" do
      dice =
        Dice.new()
        |> Dice.freeze(0)
        |> Dice.freeze(2)
        |> Dice.freeze(4)

      rolled_dice = Dice.roll(dice)

      for index <- 0..4 do
        die = Enum.at(rolled_dice.dice, index)

        if index in [0, 2, 4] do
          assert die.frozen == true
          assert die.value == 1
        else
          assert die.frozen == false
          assert die.value in 1..6
        end
      end
    end

    test "returns error tuple when given invalid dice" do
      result = Dice.roll(:invalid_dice)
      assert result == {:error, "Invalid dice provided"}
    end
  end

  describe "freeze/2" do
    test "freezes the specified die" do
      dice = Dice.new()
      target_index = 2

      updated_dice = Dice.freeze(dice, target_index)

      assert Enum.at(updated_dice.dice, target_index).frozen == true
    end

    test "only freezes the specified die" do
      dice = Dice.new()
      target_index = 1

      updated_dice = Dice.freeze(dice, target_index)

      for index <- 0..4 do
        if index != target_index do
          assert Enum.at(updated_dice.dice, index).frozen == false
        end
      end
    end

    test "freezes multiple dice when given a list of indices" do
      dice = Dice.new()
      target_indices = [0, 2, 4]

      updated_dice = Dice.freeze(dice, target_indices)

      for index <- 0..4 do
        if index in target_indices do
          assert Enum.at(updated_dice.dice, index).frozen == true
        else
          assert Enum.at(updated_dice.dice, index).frozen == false
        end
      end
    end
  end

  describe "unfreeze/2" do
    test "unfreezes the specified die" do
      target_index = 3
      dice = Dice.new() |> Dice.freeze(target_index) |> Dice.unfreeze(target_index)

      assert Enum.all?(dice.dice, fn die -> die.frozen == false end)
    end

    test "only unfreezes the specified die" do
      target_index = 3

      dice =
        Dice.new()
        |> Dice.freeze(0)
        |> Dice.freeze(1)
        |> Dice.freeze(2)
        |> Dice.freeze(3)
        |> Dice.freeze(4)

      updated_dice = Dice.unfreeze(dice, target_index)

      for index <- 0..4 do
        if index != target_index do
          assert Enum.at(updated_dice.dice, index).frozen == true
        end
      end
    end
  end

  describe "unfreeze_all/1" do
    test "unfreezes all dice" do
      dice =
        Dice.new()
        |> Dice.freeze(0)
        |> Dice.freeze(1)
        |> Dice.freeze(2)
        |> Dice.freeze(3)
        |> Dice.freeze(4)

      unfrozen_dice = Dice.unfreeze_all(dice)

      assert Enum.all?(unfrozen_dice.dice, fn die -> die.frozen == false end)
    end
  end

  describe "values/1" do
    test "returns list of die values" do
      values = Dice.new() |> Dice.values()

      assert values == [1, 1, 1, 1, 1]
    end

    test "alwasys returns values on a die" do
      values = Dice.new() |> Dice.roll() |> Dice.values()

      for value <- values do
        assert is_integer(value)
        assert value in 1..6
      end
    end

    test "always returns a list of exactly 5 values" do
      values = Dice.new() |> Dice.roll() |> Dice.values()

      assert length(values) == 5
    end
  end

  describe "get_die/2" do
    test "returns the die at the specified index" do
      target = 2
      dice = Dice.new() |> Dice.freeze(target) |> Dice.roll()

      die = Enum.at(dice.dice, target)

      assert die == %{
               value: 1,
               frozen: true
             }
    end
  end

  describe "all_frozen?/1" do
    test "returns true if all dice are frozen" do
      dice =
        Dice.new()
        |> Dice.freeze(0)
        |> Dice.freeze(1)
        |> Dice.freeze(2)
        |> Dice.freeze(3)
        |> Dice.freeze(4)

      assert Dice.all_frozen?(dice) == true
    end

    test "returns false if any die is not frozen" do
      dice =
        Dice.new()
        |> Dice.freeze(0)
        |> Dice.freeze(1)
        |> Dice.freeze(2)

      assert Dice.all_frozen?(dice) == false
    end
  end
end
