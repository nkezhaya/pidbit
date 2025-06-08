defmodule PidbitWeb.ProblemLive.Show do
  use PidbitWeb, :live_view

  alias Pidbit.{Problems, Runner}

  def mount(%{"id" => id}, _session, socket) do
    problem = Problems.get_problem!(id)
    {:ok, assign(socket, problem: problem, output: nil, loading: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="h-dvh">
      <div class="grid h-screen grid-cols-2 gap-4">
        <div class="px-4 sm:px-6 lg:px-8">
          <div class="mb-2">
            <h1 class="font-semibold">{@problem.id}. {@problem.name}</h1>
          </div>

          <div class="space-y-2">
            <.markdown md={@problem.description} />
          </div>
        </div>

        <div class="px-4 sm:px-6 lg:px-8">
          <.form for={%{}} class="h-full" phx-submit="submit">
            <LiveMonacoEditor.code_editor
              class="my-2"
              style="min-height: 250px; width: 100%;"
              value={@problem.stub}
              opts={
                Map.merge(
                  LiveMonacoEditor.default_opts(),
                  %{"language" => "elixir"}
                )
              }
            />

            <button type="submit" class="rounded-md bg-indigo-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">Submit</button>
          </.form>

          <div :if={@output}>{@output}</div>
        </div>
      </div>
    </div>
    """
  end

  def markdown(assigns) do
    markdown_html =
      assigns.md
      |> String.trim()
      |> Earmark.as_html!(code_class_prefix: "lang- language-")

    assigns = assign(assigns, :markdown, markdown_html)

    ~H"""
    {raw(@markdown)}
    """
  end

  def handle_event("submit", %{"code" => code}, socket) do
    user = Pidbit.Repo.one(Pidbit.Accounts.User)

    Task.start(fn ->
      output = Runner.run_code(user, code)
      send(self(), {:result, output})
    end)

    {:noreply, assign(socket, loading: true, output: nil)}
  end

  def handle_info({:result, output}, socket) do
    {:noreply, assign(socket, output: output, loading: false)}
  end
end
