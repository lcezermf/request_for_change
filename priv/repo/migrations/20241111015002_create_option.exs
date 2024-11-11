defmodule CraqValidator.Repo.Migrations.CreateOption do
  use Ecto.Migration

  def change do
    create table(:option) do
      add :description, :text
      add :question_id, references(:question, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:option, [:question_id])
  end
end
