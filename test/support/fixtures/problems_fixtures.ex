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
        number: 1,
        description: "some description",
        difficulty: :easy,
        name: "some name",
        slug: "some slug",
        stub: "defmodule Foo do; end"
      })
      |> Pidbit.Problems.create_problem()

    problem
  end
end
