defmodule Pidbit.Problems do
  import Ecto.Query, warn: false
  alias Pidbit.Repo

  alias Pidbit.Problems.Problem

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
end
