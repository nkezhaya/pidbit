defmodule PidbitWeb.InitAssigns do
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    socket
    |> assign_new(:current_user, fn -> current_user(session) end)
  end

  defp current_user(%{"guardian_default_token" => jwt}) when is_binary(jwt) do
    current_user(jwt)
  end

  defp current_user(%{"current_user_id" => current_user_id}) when is_binary(current_user_id) do
    Pidbit.Accounts.get_user!(current_user_id)
  end

  defp current_user(_) do
    nil
  end
end
