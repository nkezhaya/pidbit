defmodule Pidbit.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string, null: false
      add :number, :serial, null: false
      add :slug, :string, null: false
      add :difficulty, :string, null: false
      add :description, :text, null: false
      add :stub, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:problems, [:number])
    create unique_index(:problems, [:slug])
  end
end
