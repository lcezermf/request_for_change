defmodule CraqValidator.Repo.Migrations.AddRequireCommentToQuestion do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :require_comment, :boolean, default: false
    end
  end
end
