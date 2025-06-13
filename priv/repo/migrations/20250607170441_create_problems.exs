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

    execute(
      """
      CREATE OR REPLACE FUNCTION notify_problem_change()
          RETURNS TRIGGER
          AS $$
      BEGIN
          NOTIFY cached_record_updated, '';

          RETURN NULL;
      END;
      $$
      LANGUAGE plpgsql
      """,
      "DROP FUNCTION IF EXISTS notify_problem_change"
    )

    # Triggers

    execute(
      """
      CREATE TRIGGER trg_problem_change
          AFTER INSERT OR UPDATE OR DELETE ON problems FOR EACH ROW
          EXECUTE FUNCTION notify_problem_change()
      """,
      """
      DROP TRIGGER IF EXISTS trg_problem_change ON problems
      """
    )
  end
end
