defmodule RPG do
  defmodule Character do
    defstruct health: 100, mana: 0
  end

  defmodule LoafOfBread do
    defstruct []
  end

  defmodule ManaPotion do
    defstruct strength: 10
  end

  defmodule Poison do
    defstruct []
  end

  defmodule EmptyBottle do
    defstruct []
  end

  defprotocol Edible do
    def eat(item, character)
  end

  defimpl Edible, for: RPG.LoafOfBread do
    @health_increase 5
    def eat(_loaf, %RPG.Character{} = character) do
      {nil, %RPG.Character{character | health: character.health + @health_increase}}
    end
  end

  defimpl Edible, for: RPG.ManaPotion do
    def eat(potion, %RPG.Character{} = character) do
      {%RPG.EmptyBottle{}, %RPG.Character{character | mana: character.mana + potion.strength}}
    end
  end

  defimpl Edible, for: RPG.Poison do
    def eat(_poison, %RPG.Character{} = character) do
      {%RPG.EmptyBottle{}, %RPG.Character{character | health: 0}}
    end
  end
end
