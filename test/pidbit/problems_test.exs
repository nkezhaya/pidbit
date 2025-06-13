defmodule Pidbit.ProblemsTest do
  use Pidbit.DataCase

  alias Pidbit.Problems

  describe "problems" do
    alias Pidbit.Problems.Problem

    import Pidbit.ProblemsFixtures

    @invalid_attrs %{name: nil, description: nil, slug: nil, difficulty: nil}

    test "list_problems/0 returns all problems" do
      problem = problem_fixture()
      assert Problems.list_problems() == [problem]
    end

    test "get_problem!/1 returns the problem with given id" do
      problem = problem_fixture()
      assert Problems.get_problem!(problem.id) == problem
    end

    test "create_problem/1 with valid data creates a problem" do
      valid_attrs = %{
        number: 1,
        name: "some name",
        description: "some description",
        slug: "some slug",
        difficulty: :easy,
        stub: "defmodule Foo do; end"
      }

      assert {:ok, %Problem{} = problem} = Problems.create_problem(valid_attrs)
      assert problem.name == "some name"
      assert problem.description == "some description"
      assert problem.slug == "some slug"
      assert problem.difficulty == :easy
    end

    test "create_problem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Problems.create_problem(@invalid_attrs)
    end

    test "update_problem/2 with valid data updates the problem" do
      problem = problem_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        slug: "some updated slug",
        difficulty: :medium
      }

      assert {:ok, %Problem{} = problem} = Problems.update_problem(problem, update_attrs)
      assert problem.name == "some updated name"
      assert problem.description == "some updated description"
      assert problem.slug == "some updated slug"
      assert problem.difficulty == :medium
    end

    test "update_problem/2 with invalid data returns error changeset" do
      problem = problem_fixture()
      assert {:error, %Ecto.Changeset{}} = Problems.update_problem(problem, @invalid_attrs)
      assert problem == Problems.get_problem!(problem.id)
    end

    test "delete_problem/1 deletes the problem" do
      problem = problem_fixture()
      assert {:ok, %Problem{}} = Problems.delete_problem(problem)
      assert_raise Ecto.NoResultsError, fn -> Problems.get_problem!(problem.id) end
    end

    test "change_problem/1 returns a problem changeset" do
      problem = problem_fixture()
      assert %Ecto.Changeset{} = Problems.change_problem(problem)
    end
  end
end
