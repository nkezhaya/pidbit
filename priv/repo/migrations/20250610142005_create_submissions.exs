defmodule Pidbit.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :user_id, references(:users), null: false
      add :problem_id, references(:problems), null: false
      add :code, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
