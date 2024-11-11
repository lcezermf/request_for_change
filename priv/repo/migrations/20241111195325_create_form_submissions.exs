defmodule CraqValidator.Repo.Migrations.CreateFormSubmissions do
  use Ecto.Migration

  def change do
    create table(:form_submissions) do
      add :selected_option_id, :integer

      add :question_id, references(:questions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
