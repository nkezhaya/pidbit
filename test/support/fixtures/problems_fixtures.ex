defmodule Pidbit.ProblemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pidbit.Problems` context.
  """

  @doc """
  Generate a problem.
  """
  def problem_fixture(attrs \\ %{}) do
    {:ok, problem} =
      attrs
      |> Enum.into(%{
        description: "some description",
        difficulty: "some difficulty",
        name: "some name",
        slug: "some slug"
      })
      |> Pidbit.Problems.create_problem()

    problem
  end
end
