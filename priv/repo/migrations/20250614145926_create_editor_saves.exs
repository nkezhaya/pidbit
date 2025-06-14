defmodule Pidbit.Repo.Migrations.CreateEditorSaves do
  use Ecto.Migration

  def change do
    create table(:editor_saves, primary_key: false) do
      add :problem_id, references(:problems), null: false, primary_key: true
      add :user_id, references(:users), null: false, primary_key: true
      add :value, :text

      timestamps(updated_at: false)
    end
  end
end
