defmodule CraqValidator.Repo.Migrations.AddFormUuidToResponse do
  use Ecto.Migration

  def change do
    alter table(:responses) do
      add :form_public_id, :binary_id
    end
  end
end
