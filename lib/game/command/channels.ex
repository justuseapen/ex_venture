defmodule Game.Command.Channels do
  @moduledoc """
  The "global" command
  """

  use Game.Command

  alias Game.Channel

  @channels ["global", "newbie"]

  @custom_parse true
  @commands ["channels", "global", "newbie"]

  @short_help "Talk to other players"
  @full_help """
  Example: global Hello, everyone!

  This chats to players in the channel

  Turn a channel on with "{white}channel on global{/white}".
  Turn a channel off with "{white}channel off global{/white}".
  """

  @doc """
  Parse the command into arguments

      iex> Game.Command.Channels.parse("channels")
      {}

      iex> Game.Command.Channels.parse("channels off global")
      {:leave, "global"}

      iex> Game.Command.Channels.parse("channels on global")
      {:join, "global"}

      iex> Game.Command.Channels.parse("global hi")
      {"global", "hi"}

      iex> Game.Command.Channels.parse("newbie hi")
      {"newbie", "hi"}

      iex> Game.Command.Channels.parse("unknown hi")
      {:error, :bad_parse, "unknown hi"}
  """
  @spec parse(command :: String.t) :: {atom}
  def parse(command)
  def parse("channels"), do: {}
  def parse("channels off " <> channel), do: {:leave, channel}
  def parse("channels on " <> channel), do: {:join, channel}
  def parse("global " <> message), do: {"global", message}
  def parse("newbie " <> message), do: {"newbie", message}
  def parse(command), do: {:error, :bad_parse, command}

  @doc """
  Send to all connected players
  """
  def run(command, session, state)
  def run({}, _session, %{socket: socket}) do
    channels = Channel.subscribed()
    |> Enum.map(&("  - {red}#{&1}{/red}"))
    |> Enum.join("\n")

    socket |> @socket.echo("You are subscribed to:\n#{channels}")
    :ok
  end
  def run({:join, channel}, _session, %{user: user}) do
    join_channel(channel, user)
    :ok
  end
  def run({:leave, channel}, _session, %{user: user}) do
    case in_channel?(channel, user) do
      true -> Channel.leave(channel)
      false -> nil
    end
    :ok
  end
  def run({channel, message}, _session, %{user: user}) do
    case in_channel?(channel, user) do
      true -> Channel.broadcast(channel, Format.channel_say(channel, {:user, user}, message))
      false -> nil
    end
    :ok
  end

  defp in_channel?(channel, %{save: %{channels: channels}}), do: channel in channels

  defp join_channel(channel, user) when channel in @channels do
    case in_channel?(channel, user) do
      false -> Channel.join(channel)
      true -> nil
    end
  end
  defp join_channel(_channel, _user), do: nil
end
