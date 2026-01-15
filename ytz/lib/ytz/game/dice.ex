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

  def unfreeze(%__MODULE__{} = dice, index) when is_integer(index) do
    dice
    |> Map.put(
      :dice,
      List.update_at(dice.dice, index, fn die -> Map.put(die, :frozen, false) end)
    )
  end

  def unfreeze(dice, _index) when not is_struct(dice, __MODULE__) do
    {:error, "Invalid dice provided"}
  end

  def unfreeze(_dice, _index) do
    {:error, "Invalid index provided: must be int"}
  end

  def unfreeze_all(%__MODULE__{} = dice) do
    dice |> Map.put(:dice, Enum.map(dice.dice, fn die -> Map.put(die, :frozen, false) end))
  end

  def unfreeze_all(_dice) do
    {:error, "Invalid dice provided"}
  end

  def values(%__MODULE__{} = dice) do
    dice.dice
    |> Enum.map(fn die -> die.value end)
  end

  def values(_dice) do
    {:error, "Invalid dice provided"}
  end

  def get_die(%__MODULE__{} = dice, index) when is_integer(index) do
    dice.dice |> Enum.at(index)
  end

  def get_die(dice, _index) when not is_struct(dice, __MODULE__) do
    {:error, "Invalid dice provided"}
  end

  def get_die(_dice, _index) do
    {:error, "Invalid index provided: must be int"}
  end

  def all_frozen?(%__MODULE__{} = dice) do
    dice.dice |> Enum.all?(fn die -> die.frozen == true end)
  end

  def all_frozen?(_dice) do
    {:error, "Invalid dice provided"}
  end
end
