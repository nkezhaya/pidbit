defmodule PidbitWeb.ProblemLive.Index do
  use PidbitWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
      <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
        <table class="min-w-full divide-y divide-gray-300">
          <thead>
            <tr>
              <th
                scope="col"
                class="py-3.5 pr-3 pl-4 text-left text-sm font-semibold text-gray-900 sm:pl-3"
              >
                Name
              </th>
              <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Difficulty
              </th>
            </tr>
          </thead>
          <tbody class="bg-white">
            <tr :for={problem <- @problems} class="even:bg-gray-50">
              <td class="py-4 pr-3 pl-4 text-sm font-medium whitespace-nowrap text-gray-900 sm:pl-3">
                <a href={~p"/problems/#{problem}"} class="hover:underline">
                  {problem.number}. {problem.name}
                </a>
              </td>
              <td class="px-3 py-4 text-sm whitespace-nowrap text-gray-500">
                <.difficulty_tag rating={problem.difficulty} />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    problems = Pidbit.Problems.list_problems()

    {:ok,
     socket
     |> assign(page_title: "Problems", page_header: "Problems")
     |> assign(problems: problems)}
  end
end
