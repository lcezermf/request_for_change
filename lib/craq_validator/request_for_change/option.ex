defmodule CraqValidator.RequestForChange.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "option" do
    field :description, :string

    belongs_to :question, CraqValidator.RequestForChange.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
