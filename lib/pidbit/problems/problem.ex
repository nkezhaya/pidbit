defmodule Pidbit.Problems.Problem do
  @derive {Phoenix.Param, key: :slug}
  use Pidbit.Schema

  schema "problems" do
    field :name, :string
    field :number, :integer
    field :description, :string
    field :slug, :string
    field :difficulty, Ecto.Enum, values: [:easy, :medium, :hard]
    field :stub, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:name, :number, :slug, :difficulty, :description, :stub])
    |> validate_required([:name, :number, :slug, :difficulty, :description, :stub])
  end
end
