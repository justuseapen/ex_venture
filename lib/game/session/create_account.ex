defmodule Game.Session.CreateAccount do
  @moduledoc """
  Creating an account workflow

  Asks for basic information to create an account.
  """

  use Networking.Socket

  alias Game.Account
  alias Game.Class
  alias Game.Race
  alias Game.Session.Login

  @doc """
  Start text for creating an account

  This echos to the socket and ends with asking for the first field.
  """
  @spec start(socket :: pid) :: :ok
  def start(socket) do
    socket |> @socket.echo("\n\nWelcome to ExVenture.\nThank you for joining!\nWe need a name and password for you to sign up.\n")
    socket |> @socket.prompt("Name: ")
  end

  def process(password, session, state = %{socket: socket, create: %{name: name, race: race, class: class}}) do
    socket |> @socket.tcp_option(:echo, true)

    case Account.create(%{name: name, password: password}, %{race: race, class: class}) do
      {:ok, user} ->
        user |> Login.login(session, socket, state |> Map.delete(:create))
      {:error, _changeset} ->
        socket |> @socket.echo("There was a problem creating your account.\nPlease start over.")
        socket |> @socket.prompt("Name: ")
        state |> Map.delete(:create)
    end
  end
  def process(class, _session, state = %{socket: socket, create: %{name: name, race: race}}) do
    class = Class.classes
    |> Enum.find(fn (cls) -> String.downcase(cls.name) == String.downcase(class) end)

    case class do
      nil ->
        socket |> class_prompt
        state
      class ->
        socket |> @socket.prompt("Password: ")
        socket |> @socket.tcp_option(:echo, false)
        Map.merge(state, %{create: %{name: name, race: race, class: class}})
    end
  end
  def process(race_name, _session, state = %{socket: socket, create: %{name: name}}) do
    race = Race.races
    |> Enum.find(fn (race) -> String.downcase(race.name) == String.downcase(race_name) end)

    case race do
      nil ->
        socket |> race_prompt
        state
      race ->
        socket |> class_prompt()
        Map.merge(state, %{create: %{name: name, race: race}})
    end
  end
  def process(name, _session, state = %{socket: socket}) do
    socket |> race_prompt()
    Map.merge(state, %{create: %{name: name}})
  end

  defp race_prompt(socket) do
    races = Race.races
    |> Enum.map(fn (race) -> "\t- #{race.name()}" end)
    |> Enum.join("\n")

    socket |> @socket.echo("Now to pick a race. Your options are:\n#{races}")
    socket |> @socket.prompt("Race: ")
  end

  defp class_prompt(socket) do
    classes = Class.classes
    |> Enum.map(fn (class) -> "\t- #{class.name()}" end)
    |> Enum.join("\n")

    socket |> @socket.echo("Now to pick a class. Your options are:\n#{classes}")
    socket |> @socket.prompt("Class: ")
  end
end
