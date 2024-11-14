defmodule CraqValidator.Repo.Migrations.AddIsTerminalToOption do
  use Ecto.Migration

  def change do
    alter table(:options) do
      add :is_terminal, :boolean, default: false
    end
  end
end
