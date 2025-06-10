defmodule Pidbit.Problems.Submission do
  use Pidbit.Schema

  schema "submissions" do
    field :code, :string

    belongs_to :problem, Pidbit.Problems.Problem
    belongs_to :user, Pidbit.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code])
    |> validate_required([:code])
  end
end
