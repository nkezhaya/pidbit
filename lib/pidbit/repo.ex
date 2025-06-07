defmodule Pidbit.Repo do
  use Ecto.Repo,
    otp_app: :pidbit,
    adapter: Ecto.Adapters.Postgres
end
