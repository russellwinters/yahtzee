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

  @type die :: %{
          value: integer(),
          frozen: boolean()
        }
  @type t :: %__MODULE__{
          dice: [die()]
        }

  def new do
    %__MODULE__{}.dice
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

  def freeze(dice, index) do
    List.update_at(dice, index, fn die -> Map.put(die, :frozen, true) end)
  end

  # TODO: add another definition for freeze
  # That takes a list of indices to freeze multiple dice at once

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
