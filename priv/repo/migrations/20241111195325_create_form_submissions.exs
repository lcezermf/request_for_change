defmodule CraqValidator.Repo.Migrations.CreateFormSubmissions do
  use Ecto.Migration

  def change do
    create table(:form_submissions) do
      add :answers, :map

      timestamps(type: :utc_datetime)
    end
  end
end
