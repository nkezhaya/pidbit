alias Pidbit.Repo
alias Pidbit.Problems.Problem

%Problem{
  id: 1,
  name: "Hello World",
  slug: "hello-world",
  difficulty: :easy,
  description: """
  Write a function that returns `"Hello, world!"`
  """
}
|> Repo.insert!(on_conflict: :replace_all, conflict_target: [:id])
