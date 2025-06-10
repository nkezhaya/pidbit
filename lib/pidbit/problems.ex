defmodule Pidbit.Problems do
  import Ecto.Query, warn: false

  alias Pidbit.Accounts.User
  alias Pidbit.Repo

  alias __MODULE__.{Problem, Submission}

  def list_problems do
    Problem
    |> order_by(:id)
    |> Repo.all()
  end

  def get_problem!(id), do: Repo.get!(Problem, id)

  def create_problem(attrs \\ %{}) do
    %Problem{}
    |> Problem.changeset(attrs)
    |> Repo.insert()
  end

  def update_problem(%Problem{} = problem, attrs) do
    problem
    |> Problem.changeset(attrs)
    |> Repo.update()
  end

  def delete_problem(%Problem{} = problem) do
    Repo.delete(problem)
  end

  def change_problem(%Problem{} = problem, attrs \\ %{}) do
    Problem.changeset(problem, attrs)
  end

  def create_submission(%Problem{} = problem, %User{} = user, code) do
    %Submission{problem_id: problem.id, user_id: user.id}
    |> Submission.changeset(%{code: code})
    |> Repo.insert()
  end
end
