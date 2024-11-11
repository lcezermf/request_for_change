defmodule CraqValidator.Repo.Migrations.CreateOption do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :description, :text
      add :question_id, references(:questions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:options, [:question_id])
  end
end
