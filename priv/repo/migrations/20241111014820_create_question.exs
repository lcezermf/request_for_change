defmodule CraqValidator.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table(:question) do
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
