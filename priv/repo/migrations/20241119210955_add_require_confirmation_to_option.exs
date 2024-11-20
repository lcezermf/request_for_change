defmodule CraqValidator.Repo.Migrations.AddRequireConfirmationToOption do
  use Ecto.Migration

  def change do
    alter table(:options) do
      add :require_confirmation, :boolean, default: false
    end
  end
end
