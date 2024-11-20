defmodule CraqValidator.Repo.Migrations.AddConfirmationsToResponse do
  use Ecto.Migration

  def change do
    alter table(:responses) do
      add :confirmations, {:array, :integer}
    end
  end
end
