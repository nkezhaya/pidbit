defmodule Pidbit.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :user_id, references(:users), null: false
      add :problem_id, references(:problems), null: false
      add :code, :text, null: false
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime_usec)
    end

    create index(:submissions, [:user_id, "inserted_at DESC"])
  end
end
