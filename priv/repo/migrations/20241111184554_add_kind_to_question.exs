defmodule CraqValidator.Repo.Migrations.AddKindToQuestion do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :kind, :string
    end
  end
end
