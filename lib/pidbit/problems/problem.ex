defmodule Pidbit.Problems.Problem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "problems" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :difficulty, Ecto.Enum, values: [:easy, :medium, :hard]
    field :stub, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:name, :slug, :difficulty, :description, :stub])
    |> validate_required([:name, :slug, :difficulty, :description, :stub])
  end
end
