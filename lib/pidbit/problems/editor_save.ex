defmodule Pidbit.Problems.EditorSave do
  use Pidbit.Schema

  @type t() :: %__MODULE__{}

  @primary_key false
  schema "editor_saves" do
    field :value, :string

    belongs_to :problem, Pidbit.Problems.Problem, primary_key: true
    belongs_to :user, Pidbit.Accounts.User, primary_key: true

    timestamps(updated_at: false, type: :utc_datetime_usec)
  end

  @doc false
  def changeset(editor_save, attrs) do
    cast(editor_save, attrs, [:value])
  end
end
