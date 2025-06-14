defmodule Pidbit.Problems do
  import Ecto.Query, warn: false

  alias Pidbit.Accounts.User
  alias Pidbit.Repo

  alias __MODULE__.{Problem, Submission}

  @typep result(t) :: {:ok, t} | {:error, Ecto.Changeset.t()}

  @spec list_problems() :: [Problem.t()]
  def list_problems do
    Problem
    |> order_by(:number)
    |> Repo.all()
  end

  @spec get_problem!(Ecto.UUID.t()) :: Problem.t()
  def get_problem!(id), do: Repo.get!(Problem, id)

  @spec get_problem_by_slug!(String.t()) :: Problem.t()
  def get_problem_by_slug!(slug), do: Repo.get_by!(Problem, slug: slug)

  @spec create_problem(map()) :: result(Problem.t())
  def create_problem(attrs \\ %{}) do
    %Problem{}
    |> Problem.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_problem(Problem.t(), map()) :: result(Problem.t())
  def update_problem(%Problem{} = problem, attrs) do
    problem
    |> Problem.changeset(attrs)
    |> Repo.update()
  end

  @spec change_problem(Problem.t(), map()) :: Ecto.Changeset.t()
  def change_problem(%Problem{} = problem, attrs \\ %{}) do
    Problem.changeset(problem, attrs)
  end

  @spec create_submission(Problem.t(), User.t(), String.t()) :: result(Submission.t())
  def create_submission(%Problem{} = problem, %User{} = user, code) do
    %Submission{problem: problem, problem_id: problem.id, user_id: user.id}
    |> Submission.changeset(%{code: code})
    |> Repo.insert()
  end

  @spec put_submission_status!(Submission.t(), Submission.status()) :: Submission.t()
  def put_submission_status!(%Submission{} = submission, status) do
    submission
    |> Submission.changeset(%{status: status})
    |> Repo.update!()
  end
end
