defmodule Myflightmap.Accounts.User do
  @moduledoc """
  Schema for users
  """

  use Myflightmap.Schema
  import Ecto.Changeset
  alias Myflightmap.Accounts.Credential

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string
    field :username, :string
    field :trip_email_id, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :trip_email_id])
    |> validate_required([:username])
    |> update_change(:username, &normalize_username/1)
    |> validate_length(:username, min: 2, max: 30)
    |> unique_constraint(:username)
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast_assoc(:credential, with: &Credential.changeset/2)
  end

  # Trim and downcase will allow the database unique constraint to work without
  # the need for a function in the index definition or using Postgres `citext`
  def normalize_username(str) do
    str
    |> String.trim()
    |> String.downcase()
  end
end
