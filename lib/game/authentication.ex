defmodule Game.Authentication do
  @moduledoc """
  Find and validate a user
  """
  import Ecto.Query

  alias Data.Repo
  alias Data.Skill
  alias Data.User

  @doc """
  Attempt to find a user and validate their password
  """
  @spec find_and_validate(name :: String.t, password :: String.t) :: {:error, :invalid} | User.t
  def find_and_validate(name, password) do
    User
    |> where([u], u.name == ^name)
    |> preloads()
    |> Repo.one
    |> _find_and_validate(password)
  end

  defp _find_and_validate(nil, _password) do
    Comeonin.Bcrypt.dummy_checkpw
    {:error, :invalid}
  end
  defp _find_and_validate(user, password) do
    case Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      true -> user
      _ -> {:error, :invalid}
    end
  end

  @doc """
  Find a user by an id and preload properly
  """
  @spec find_user(user_id :: integer) :: nil | User.t
  def find_user(user_id) do
    User
    |> where([u], u.id == ^user_id)
    |> preloads()
    |> Repo.one
  end

  defp preloads(query) do
    query
    |> preload([:race])
    |> preload([class: [skills: ^(from s in Skill, order_by: [s.level, s.id])]])
  end
end
