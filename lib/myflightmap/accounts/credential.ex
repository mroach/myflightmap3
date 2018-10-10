defmodule Myflightmap.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Myflightmap.Accounts.User

  schema "credentials" do
    field :email, :string
    field :password_hash, :string
    belongs_to :user_id, User

    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password_hash])
    |> update_change(:email, &normalize_email/1)
    |> validate_required([:email, :password_hash])
    |> validate_length(:email, min: 3)
    |> unique_constraint(:email)
    |> put_hashed_password()
  end

  # Trim and downcase will allow the database unique constraint to work without
  # the need for a function in the index definition or using Postgres `citext`
  def normalize_email(str) do
    str
    |> String.trim
    |> String.downcase
  end

  def put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password)
      _ ->
        changeset
    end
  end
end
