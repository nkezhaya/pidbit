defmodule PidbitWeb.ProblemLive.Show do
  use PidbitWeb, :live_view

  alias Pidbit.{Problems, Runner}

  def mount(%{"id" => id}, _session, socket) do
    problem = Problems.get_problem!(id)

    {:ok,
     socket
     |> assign(page_title: problem.name, page_header: "#{problem.number}. #{problem.name}")
     |> assign(problem: problem, loading: false)
     |> assign(code: problem.stub, output: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="grid h-screen grid-cols-2 gap-4">
      <div>
        <div id="ProblemDescription" class="space-y-3">
          <.markdown md={@problem.description} />
        </div>
      </div>

      <div>
        <LiveMonacoEditor.code_editor
          class="my-2"
          style="min-height: 250px; width: 100%;"
          value={@code}
          change="editor_update"
          opts={
            Map.merge(
              LiveMonacoEditor.default_opts(),
              %{"language" => "elixir"}
            )
          }
        />

        <button
          type="button"
          phx-click="submit"
          disabled={@output && !@output.ok?}
          class="rounded-md bg-indigo-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 cursor-pointer"
        >
          <%= if @output && @output.loading do %>
            Submitting...
          <% else %>
            Submit
          <% end %>
        </button>

        <div :if={output = @output && @output.ok? && @output.result} class="mt-2 overflow-scroll">
          {raw(output)}
        </div>
      </div>
    </div>
    """
  end

  def markdown(assigns) do
    markdown_html =
      assigns.md
      |> String.trim()
      |> MDEx.to_html!()

    assigns = assign(assigns, :markdown, markdown_html)

    ~H"""
    {raw(@markdown)}
    """
  end

  def handle_event("editor_update", %{"value" => code}, socket) do
    {:noreply, assign(socket, code: code)}
  end

  def handle_event("submit", _, socket) do
    user = Pidbit.Repo.one(Pidbit.Accounts.User)
    %{code: code, problem: problem} = socket.assigns

    case Problems.create_submission(problem, user, code) do
      {:ok, submission} ->
        {:noreply,
         socket
         |> assign(:output, nil)
         |> assign_async(:output, fn ->
           output =
             """
             ```
             #{Runner.run_submission(submission)}
             ```
             """
             |> String.trim()
             |> MDEx.to_html!()

           {:ok, %{output: output}}
         end)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info({:result, output}, socket) do
    {:noreply, assign(socket, output: output, loading: false)}
  end
end
