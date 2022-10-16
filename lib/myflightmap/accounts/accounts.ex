defmodule Myflightmap.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Myflightmap.Accounts.User
  alias Myflightmap.Repo

  @doc """
  Register a new user and create a `Credential`
  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) when is_binary(email) do
    query =
      from u in User,
        join: c in assoc(u, :credential),
        where: c.email == ^email

    query
    |> Repo.one()
    |> Repo.preload(:credential)
  end

  def get_user_by_trip_email_id(trip_email_id) when is_binary(trip_email_id) do
    query =
      from u in User,
        where: u.trip_email_id == ^trip_email_id

    Repo.one(query)
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
    |> case do
      {:ok, user} ->
        maybe_set_user_trip_email_id(user)

      err ->
        err
    end
  end

  @doc """
  If the given `User` doesn't have a `trip_email_id` set, generate one using
  the `Myflightmap.UserEmailId.encode/1` generator.
  """
  @spec maybe_set_user_trip_email_id(User.t()) :: {:ok, User.t()}
  def maybe_set_user_trip_email_id(%User{id: uid, trip_email_id: nil} = user) do
    email_id = Myflightmap.UserEmailId.encode(uid)
    update_user(user, %{trip_email_id: email_id})
  end

  def maybe_set_user_trip_email_id(%User{} = user), do: {:ok, user}

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
