defmodule CraqValidator.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :option_id, :integer
      add :comment, :text
      add :question_id, references(:questions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:responses, [:question_id])
  end
end
