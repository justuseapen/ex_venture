defmodule Game.Shop.ActionTest do
  use Data.ModelCase

  alias Data.Shop
  alias Game.Items
  alias Game.Shop.Action

  describe "buying items" do
    setup do

      shop = %Shop{name: "Tree Top Shop"}
      item = item_attributes(%{id: 1, name: "Sword", keywords: []})
      save = %{base_save() | currency: 100}

      Items.start_link
      Agent.update(Items, fn (_) -> %{item.id => item} end)

      shop = %{shop | shop_items: [%{id: 2, item_id: item.id, price: 10, quantity: 10}]}

      %{shop: shop, item: item, save: save}
    end

    test "successfully buy an item", %{shop: shop, item: item, save: save} do
      {:ok, save, ^item, shop} = Action.buy(shop, "sword", save)

      assert save.currency == 90
      assert save.item_ids == [item.id]
      assert [%{quantity: 9}] = shop.shop_items
    end

    test "quantity is unlimited", %{shop: shop, item: item, save: save} do
      shop = %{shop | shop_items: [%{id: 2, item_id: item.id, price: 10, quantity: -1}]}

      {:ok, save, ^item, shop} = Action.buy(shop, "sword", save)

      assert save.currency == 90
      assert [%{quantity: -1}] = shop.shop_items
    end

    test "item not found", %{shop: shop, save: save} do
      save = %{save | currency: 5}

      {:error, :item_not_found} = Action.buy(shop, "swrd", save)
    end

    test "not enough currency in the save", %{shop: shop, item: item, save: save} do
      save = %{save | currency: 5}

      {:error, :not_enough_currency, ^item} = Action.buy(shop, "sword", save)
    end

    test "not enough quantity in the shop", %{shop: shop, item: item, save: save} do
      shop = %{shop | shop_items: [%{id: 2, item_id: item.id, price: 10, quantity: 0}]}

      {:error, :not_enough_quantity, ^item} = Action.buy(shop, "sword", save)
    end
  end
end
