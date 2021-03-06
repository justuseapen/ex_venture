defmodule Game.Command.Drop do
  @moduledoc """
  The "drop" command
  """

  use Game.Command
  use Game.Currency

  alias Game.Items

  @commands ["drop"]
  @must_be_alive true

  @short_help "Drop an item in the same room"
  @full_help """
  Example: drop sword
  """

  @doc """
  #{@short_help}
  """
  @spec run(args :: [], session :: Session.t, state :: map) :: :ok | {:update, map}
  def run(command, session, state)
  def run({item_name}, _session, state) do
    case Regex.match?(~r{#{@currency}}, item_name) do
      true -> drop_currency(item_name, state)
      false -> drop_item(item_name, state)
    end
  end

  defp drop_currency(amount_to_drop, state = %{socket: socket, save: %{currency: currency}}) do
    amount = amount_to_drop
    |> String.split(" ")
    |> List.first
    |> String.to_integer()

    case currency - amount >= 0 do
      true -> _drop_currency(amount, state)
      false ->
        socket |> @socket.echo("You do not have enough #{currency()} to drop #{amount}.")
        :ok
    end
  end

  defp _drop_currency(amount, state = %{socket: socket, save: %{currency: currency}}) do
    save = %{state.save | currency: currency - amount}
    socket |> @socket.echo("You dropped #{amount} #{currency()}")
    @room.drop_currency(save.room_id, {:user, state.user}, amount)
    {:update, Map.put(state, :save, save)}
  end

  defp drop_item(item_name, state = %{socket: socket, save: %{item_ids: item_ids}}) do
    items = Items.items(item_ids)
    case Enum.find(items, &(Game.Item.matches_lookup?(&1, item_name))) do
      nil ->
        socket |> @socket.echo(~s(Could not find "#{item_name}"))
        :ok
      item -> _drop_item(item, state)
    end
  end

  defp _drop_item(item, state = %{socket: socket, user: user, save: save}) do
    save = %{save | item_ids: List.delete(save.item_ids, item.id)}
    socket |> @socket.echo("You dropped #{item.name}")
    @room.drop(save.room_id, {:user, user}, item)
    {:update, Map.put(state, :save, save)}
  end
end
