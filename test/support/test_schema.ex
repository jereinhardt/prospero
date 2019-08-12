defmodule Prospero.TestSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "test_schema" do
    field :name, :string
    field :age, :integer
  end

  @doc false
  def changeset(character, attrs \\ %{}) do
    character
    |> cast(attrs, [:name, :age])
    |> validate_required([:name, :age])
  end
end