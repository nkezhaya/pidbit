defmodule PidbitWeb.HomeLive do
  use PidbitWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: ~p"/problems")}
  end
end
