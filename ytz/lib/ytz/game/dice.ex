defmodule Ytz.Game.Dice do
  @moduledoc """
  TODO: implement module doc after implementation
  """

  defstruct dice: [
              %{value: 1, frozen: false},
              %{value: 1, frozen: false},
              %{value: 1, frozen: false},
              %{value: 1, frozen: false},
              %{value: 1, frozen: false}
            ]

  # TODO: Consider if we should have anyther type that is more central, or if we need a handlers in Dice to
  # Better convert and manipulate the dice themselves. I want
  # To think like I'm interacting with an array of die, but
  # from what I've seen we can't actually make the struct an array
  # So we kind of need to have the dice field be the array, and then
  # have functions that manipulate that field directly

  @type die :: %{
          value: integer(),
          frozen: boolean()
        }
  @type t :: %__MODULE__{
          dice: [die()]
        }

  def new do
    %__MODULE__{}
  end

  def roll(dice) do
    Enum.map(dice, fn die ->
      if die.frozen do
        die
      else
        Map.put(die, :value, :rand.uniform(6))
      end
    end)
  end

  # TODO: function to extract_values, taking a Dice struct and returning a list of the values

  def freeze(%__MODULE__{} = dice, target) when is_integer(target) do
    updated_list = List.update_at(dice.dice, target, fn die -> Map.put(die, :frozen, true) end)
    %__MODULE__{dice: updated_list}
  end

  def freeze(%__MODULE__{} = dice, target) when is_list(target) do
    targets = MapSet.new(target)

    updated_list =
      Enum.reduce(0..4, dice.dice, fn index, acc ->
        if MapSet.member?(targets, index) do
          List.update_at(acc, index, fn die -> Map.put(die, :frozen, true) end)
        else
          acc
        end
      end)

    %__MODULE__{dice: updated_list}
  end

  def freeze(dice, _target) when not is_struct(dice, __MODULE__) do
    {:error, "Invalid dice provided"}
  end

  def freeze(_dice, _target) do
    {:error, "Invalid target"}
  end

  def unfreeze(dice, index) do
    List.update_at(dice, index, fn die -> Map.put(die, :frozen, false) end)
  end

  def unfreeze_all(dice) do
    Enum.map(dice, fn die -> Map.put(die, :frozen, false) end)
  end

  def values(dice) do
    Enum.map(dice, fn die -> die.value end)
  end

  def get_die(dice, index) do
    Enum.at(dice, index)
  end

  def all_frozen?(dice) do
    Enum.all?(dice, fn die -> die.frozen == true end)
  end
end
