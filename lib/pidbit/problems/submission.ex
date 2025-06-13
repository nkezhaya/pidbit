defmodule Pidbit.Problems.Submission do
  use Pidbit.Schema

  @statuses [:pending, :ok, :compile_error, :test_failure]
  @type status() :: :pending | :ok | :compile_error | :test_failure
  @type t() :: %__MODULE__{status: status()}

  schema "submissions" do
    field :code, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :output, :string, virtual: true

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

  @spec status_from_exit_code(0 | 1 | 2) :: status()
  def status_from_exit_code(0), do: :ok
  def status_from_exit_code(1), do: :compile_error
  def status_from_exit_code(2), do: :test_failure
end
