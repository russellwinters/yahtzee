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

  def roll(%__MODULE__{} = dice) do
    updated =
      Enum.map(dice.dice, fn die ->
        if die.frozen do
          die
        else
          Map.put(die, :value, :rand.uniform(6))
        end
      end)

    %__MODULE__{dice: updated}
  end

  def roll(dice) when not is_struct(dice, __MODULE__) do
    {:error, "Invalid dice provided"}
  end

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
    dice
    |> Map.put(
      :dice,
      List.update_at(dice.dice, index, fn die -> Map.put(die, :frozen, false) end)
    )
  end

  def unfreeze_all(dice) do
    dice |> Map.put(:dice, Enum.map(dice.dice, fn die -> Map.put(die, :frozen, false) end))
  end

  def values(dice) do
    dice.dice
    |> Enum.map(fn die -> die.value end)
  end

  def get_die(dice, index) do
    dice.dice |> Enum.at(index)
  end

  def all_frozen?(dice) do
    dice.dice |> Enum.all?(fn die -> die.frozen == true end)
  end
end
