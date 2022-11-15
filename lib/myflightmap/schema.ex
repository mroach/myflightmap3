defmodule Myflightmap.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: false, read_after_writes: true}
      @foreign_key_type :binary_id
    end
  end
end
