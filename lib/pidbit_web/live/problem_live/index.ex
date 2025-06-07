defmodule PidbitWeb.ProblemLive.Index do
  use PidbitWeb, :live_view

  def mount(_params, _session, socket) do
    problems = Pidbit.Problems.list_problems()
    {:ok, assign(socket, problems: problems)}
  end

  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold text-gray-900">Problems</h1>
        </div>
      </div>
      <div class="mt-8 flow-root">
        <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <table class="min-w-full divide-y divide-gray-300">
              <thead>
                <tr>
                  <th scope="col" class="py-3.5 pr-3 pl-4 text-left text-sm font-semibold text-gray-900 sm:pl-3">Name</th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Difficulty</th>
                </tr>
              </thead>
              <tbody class="bg-white">
                <tr :for={problem <- @problems} class="even:bg-gray-50">
                  <td class="py-4 pr-3 pl-4 text-sm font-medium whitespace-nowrap text-gray-900 sm:pl-3">
                    <a href={~p"/problems/#{problem.id}"} class="hover:underline">
                      {problem.id}. {problem.name}
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
      </div>
    </div>
    """
  end

  defp difficulty_tag(assigns) do
    color =
      case assigns.rating do
        :easy -> "bg-green-100 text-green-700"
        :medium -> "bg-yellow-100 text-yellow-800"
        :hard -> "bg-red-100 text-red-700"
      end

    assigns = assign(assigns, :color, color)

    ~H"""
    <span class={"inline-flex items-center rounded-full px-2 py-1 text-xs font-medium #{@color}"}>
      {@rating}
    </span>
    """
  end
end
