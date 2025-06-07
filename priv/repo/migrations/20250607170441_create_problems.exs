defmodule Pidbit.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :difficulty, :string, null: false
      add :description, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
