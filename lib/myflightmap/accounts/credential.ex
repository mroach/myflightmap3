defmodule Myflightmap.Accounts.Credential do
  @moduledoc """
  Optional single (one to zero or one) record for a User that stores
  their login credentials with an email address and hashed password
  """

  use Myflightmap.Schema
  import Ecto.Changeset
  alias Myflightmap.Accounts.User

  schema "credentials" do
    field :email, :string
    field :password_hash, :string
    belongs_to :user, User, references: :binary_id

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> update_change(:email, &normalize_email/1)
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_confirmation(:password, message: "does not match")
    |> validate_length(:email, min: 3)
    |> unique_constraint(:email)
    |> put_hashed_password()
    |> foreign_key_constraint(:user_id)
  end

  # Trim and downcase will allow the database unique constraint to work without
  # the need for a function in the index definition or using Postgres `citext`
  def normalize_email(str) do
    str
    |> String.trim()
    |> String.downcase()
  end

  def put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
