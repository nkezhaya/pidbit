defmodule Pidbit.Problems.Submission do
  use Pidbit.Schema

  @type t() :: %__MODULE__{}
  @type status() :: :pending | :failed | :passed

  schema "submissions" do
    field :code, :string
    field :status, Ecto.Enum, values: [:pending, :failed, :passed], default: :pending

    belongs_to :problem, Pidbit.Problems.Problem
    belongs_to :user, Pidbit.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code, :status])
    |> validate_required([:code, :status])
  end
end
