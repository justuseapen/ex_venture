defmodule Game.Command.Emote do
  @moduledoc """
  The "emote" command
  """

  use Game.Command

  @commands ["emote"]

  @short_help "Does an emote"
  @full_help """
  Example: emote does something
  """

  @doc """
  Perform an emote
  """
  @spec run(args :: [], session :: Session.t, state :: map) :: :ok
  def run(command, session, state)
  def run({emote}, session, %{socket: socket, user: user, save: %{room_id: room_id}}) do
    socket |> @socket.echo(Format.emote({:user, user}, emote))
    room_id |> @room.emote(session, Message.emote(user, emote))
    :ok
  end
end
