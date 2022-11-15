defmodule Myflightmap.Repo.Migrations.EnablePgcrypto do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"
  end
end
