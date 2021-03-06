defmodule Game.FormatTest do
  use ExUnit.Case
  doctest Game.Format

  alias Game.Format

  describe "line wrapping" do
    test "single line" do
      assert Format.wrap("one line") == "one line"
    end

    test "wraps at 80 chars" do
      assert Format.wrap("this line will be split up into two lines because it is longer than 80 characters") ==
        "this line will be split up into two lines because it is longer than 80\ncharacters"
    end
  end

  describe "inventory formatting" do
    setup do
      wearing = %{chest: %{name: "Leather Armor"}}
      wielding = %{right: %{name: "Short Sword"}, left: %{name: "Shield"}}
      items = [%{name: "Potion"}, %{name: "Dagger"}]

      %{currency: 10, wearing: wearing, wielding: wielding, items: items}
    end

    test "displays currency", %{currency: currency, wearing: wearing, wielding: wielding, items: items} do
      Regex.match?(~r/You have 10 gold/, Format.inventory(currency, wearing, wielding, items))
    end

    test "displays wielding", %{currency: currency, wearing: wearing, wielding: wielding, items: items} do
      Regex.match?(~r/You are wielding/, Format.inventory(currency, wearing, wielding, items))
      Regex.match?(~r/- a {cyan}Shield{\/cyan} in your left hand/, Format.inventory(currency, wearing, wielding, items))
      Regex.match?(~r/- a {cyan}Short Sword{\/cyan} in your right hand/, Format.inventory(currency, wearing, wielding, items))
    end

    test "displays wearing", %{currency: currency, wearing: wearing, wielding: wielding, items: items} do
      Regex.match?(~r/You are wearing/, Format.inventory(currency, wearing, wielding, items))
      Regex.match?(~r/- a {cyan}Leather Armor{\/cyan} on your chest/, Format.inventory(currency, wearing, wielding, items))
    end

    test "displays items", %{currency: currency, wearing: wearing, wielding: wielding, items: items} do
      Regex.match?(~r/You are holding:/, Format.inventory(currency, wearing, wielding, items))
      Regex.match?(~r/- {cyan}Potion{\/cyan}/, Format.inventory(currency, wearing, wielding, items))
      Regex.match?(~r/- {cyan}Dagger{\/cyan}/, Format.inventory(currency, wearing, wielding, items))
    end
  end

  describe "room formatting" do
    setup do
      room = %{
        id: 1,
        name: "Hallway",
        description: "A hallway",
        currency: 100,
        players: [%{name: "Player"}],
        npcs: [%{name: "Bandit"}],
        exits: [%{south_id: 1}, %{west_id: 1}],
        items: [%{name: "Sword"}],
        shops: [%{name: "Hole in the Wall"}],
      }

      %{room: room}
    end

    test "includes the room name", %{room: room} do
      assert Regex.match?(~r/Hallway/, Format.room(room))
    end

    test "includes the room description", %{room: room} do
      assert Regex.match?(~r/A hallway/, Format.room(room))
    end

    test "includes the room exits", %{room: room} do
      assert Regex.match?(~r/north/, Format.room(room))
      assert Regex.match?(~r/east/, Format.room(room))
    end

    test "includes currency", %{room: room} do
      assert Regex.match?(~r/100 gold/, Format.room(room))
    end

    test "includes the room items", %{room: room} do
      assert Regex.match?(~r/Sword/, Format.room(room))
    end

    test "includes the players", %{room: room} do
      assert Regex.match?(~r/Player/, Format.room(room))
    end

    test "includes the npcs", %{room: room} do
      assert Regex.match?(~r/Bandit/, Format.room(room))
    end

    test "includes the shops", %{room: room} do
      assert Regex.match?(~r/Hole in the Wall/, Format.room(room))
    end
  end

  describe "info formatting" do
    setup do
      stats = %{
        health: 50,
        max_health: 55,
        skill_points: 10,
        max_skill_points: 10,
        strength: 10,
        intelligence: 10,
        dexterity: 10,
      }

      save = %Data.Save{level: 1, experience_points: 0, stats: stats}

      user = %{
        name: "hero",
        save: save,
        race: %{name: "Human"},
        class: %{name: "Fighter", points_name: "Skill Points"},
        seconds_online: 61,
      }

      %{user: user}
    end

    test "includes player name", %{user: user} do
      assert Regex.match?(~r/hero/, Format.info(user))
    end

    test "includes player race", %{user: user} do
      assert Regex.match?(~r/Human/, Format.info(user))
    end

    test "includes player class", %{user: user} do
      assert Regex.match?(~r/Fighter/, Format.info(user))
    end

    test "includes player level", %{user: user} do
      assert Regex.match?(~r/Level.+|.+1/, Format.info(user))
    end

    test "includes player xp", %{user: user} do
      assert Regex.match?(~r/XP.+|.+0/, Format.info(user))
    end

    test "includes player health", %{user: user} do
      assert Regex.match?(~r/Health.+|.+50\/55/, Format.info(user))
    end

    test "includes player skill points", %{user: user} do
      assert Regex.match?(~r/Skill Points.+|.+10\/10/, Format.info(user))
    end

    test "includes player strength", %{user: user} do
      assert Regex.match?(~r/Strength.+|.+10/, Format.info(user))
    end

    test "includes player intelligence", %{user: user} do
      assert Regex.match?(~r/Intelligence.+|.+10/, Format.info(user))
    end

    test "includes player dexterity", %{user: user} do
      assert Regex.match?(~r/Dexterity.+|.+10/, Format.info(user))
    end

    test "includes player play time", %{user: user} do
      assert Regex.match?(~r/Play Time.+|.+00h 01m 01s/, Format.info(user))
    end
  end

  describe "shop listing" do
    setup do
      sword = %{name: "Sword", price: 100, quantity: 10}
      shield = %{name: "Shield", price: 80, quantity: -1}
      %{shop: %{name: "Tree Top Stand"}, items: [sword, shield]}
    end

    test "includes shop name", %{shop: shop, items: items} do
      assert Regex.match?(~r/Tree Top Stand/, Format.list_shop(shop, items))
    end

    test "includes shop items", %{shop: shop, items: items} do
      assert Regex.match?(~r/100 gold/, Format.list_shop(shop, items))
      assert Regex.match?(~r/10 left/, Format.list_shop(shop, items))
      assert Regex.match?(~r/Sword/, Format.list_shop(shop, items))
    end

    test "-1 quantity is unlimited", %{shop: shop, items: items} do
      assert Regex.match?(~r/unlimited/, Format.list_shop(shop, items))
    end
  end
end
