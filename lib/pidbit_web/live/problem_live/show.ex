defmodule PidbitWeb.ProblemLive.Show do
  use PidbitWeb, :live_view
  require Pidbit.Cache

  alias Pidbit.{Cache, Problems, Runner}

  on_mount {PidbitWeb.UserAuth, :mount_current_user}

  def render(assigns) do
    ~H"""
    <div class="grid h-screen grid-cols-2 gap-4">
      <div id="ProblemDescription" class="space-y-3">
        <.markdown md={@problem.description} />
      </div>

      <div class="space-y-4">
        <div class="flex justify-end">
          <button
            type="button"
            class="rounded-sm bg-indigo-50 px-2 py-1 text-xs font-semibold text-indigo-600 shadow-xs hover:bg-indigo-100 cursor-pointer"
            phx-click="reset_editor"
          >
            Reset
          </button>
        </div>

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

        <.submit signed_in={not is_nil(@current_user)} output={@output} />

        <div :if={is_nil(@current_user)} class="text-sm/6 text-gray-500">
          <.link
            navigate={~p"/users/log_in"}
            class="font-semibold text-indigo-600 hover:text-indigo-500"
          >
            Log in
          </.link>
          to submit a solution.
        </div>

        <div :if={output = @output && @output.ok? && @output.result} class="mt-2 overflow-scroll">
          <%= case elem(output, 0) do %>
            <% :ok -> %>
              <div class="text-green-400">Success!</div>
            <% :compile_error -> %>
              <div class="text-red-400">Compile Error</div>
            <% :test_failure -> %>
              <div class="text-red-400">Test Failure</div>
          <% end %>

          {raw(elem(output, 1))}
        </div>
      </div>
    </div>
    """
  end

  defp submit(%{signed_in: signed_in, output: output} = assigns) do
    assigns = assign(assigns, :disabled, !!(not signed_in || (output && output.loading)))

    ~H"""
    <button
      type="button"
      phx-click="submit"
      disabled={@disabled}
      class={"rounded-md #{if @disabled, do: "bg-indigo-300", else: "bg-indigo-600 hover:bg-indigo-500 cursor-pointer"} px-2.5 py-1.5 text-sm font-semibold text-white shadow-xs focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"}
    >
      <%= if @output && @output.loading do %>
        Submitting...
      <% else %>
        Submit
      <% end %>
    </button>
    """
  end

  defp markdown(assigns) do
    markdown_html =
      assigns.md
      |> String.trim()
      |> MDEx.to_html!(syntax_highlight: [formatter: {:html_inline, theme: "xcode_light"}])

    assigns = assign(assigns, :markdown, markdown_html)

    ~H"""
    {raw(@markdown)}
    """
  end

  def mount(%{"slug" => slug}, _session, socket) do
    problem =
      Cache.fetch {:get_problem_by_slug!, slug} do
        Problems.get_problem_by_slug!(slug)
      end

    code = Problems.get_editor_value!(problem, socket.assigns.current_user)

    {:ok,
     socket
     |> assign(page_title: problem.name, page_header: "#{problem.number}. #{problem.name}")
     |> assign(problem: problem, loading: false)
     |> assign(code: code, output: nil)}
  end

  def handle_event("reset_editor", _params, %{assigns: %{problem: problem}} = socket) do
    {:noreply, LiveMonacoEditor.set_value(socket, problem.stub)}
  end

  def handle_event("editor_update", %{"value" => code}, socket) do
    %{problem: problem, current_user: current_user} = socket.assigns

    if current_user do
      Problems.persist_editor_value!(problem, current_user, code)
    end

    {:noreply, assign(socket, code: code)}
  end

  def handle_event("submit", _, socket) do
    %{code: code, problem: problem, current_user: current_user} = socket.assigns

    case Problems.create_submission(problem, current_user, code) do
      {:ok, submission} ->
        {:noreply,
         socket
         |> assign(:output, nil)
         |> assign_async(:output, fn ->
           submission = Runner.run_submission(submission)

           output =
             case submission.output do
               "" ->
                 nil

               output ->
                 """
                 ```
                 #{output}
                 ```
                 """
                 |> String.trim()
                 |> MDEx.to_html!()
             end

           {:ok, %{output: {submission.status, output}}}
         end)}

      _ ->
        {:noreply, socket}
    end
  end
end
