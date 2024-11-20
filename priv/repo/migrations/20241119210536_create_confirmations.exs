defmodule CraqValidator.Repo.Migrations.CreateConfirmations do
  use Ecto.Migration

  def change do
    create table(:confirmations) do
      add :description, :string
      add :option_id, references(:options, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
