defmodule Myflightmap.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Myflightmap.Accounts.{Credential, User}
  alias Myflightmap.Repo

  def authenticate_by_email(email, pass) do
    email
    |> get_user_by_email()
    |> authenticate_with_password(pass)
  end

  def authenticate_with_password(%User{} = user, pass) do
    if Comeonein.Bcrypt.checkpw(pass, user.credential.password_hash) do
      {:ok, user}
    else
      Comeone.Bcrypt.dummy_checkpw()
      {:error, :unauthorized}
    end
  end

  def authenticate_with_password(_, _) do
    {:error, :not_found}
  end
  
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert
  end

  def get_user_by_email(email) when is_binary(email) do
    from(u in User, join: c in assoc(u, :credential), where: c.email == ^email)
    |> Repo.one
    |> Repo.preload(:credential)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: User |> Repo.get!(id) |> Repo.preload(:credential)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
