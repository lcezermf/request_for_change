defmodule CraqValidator.RequestForChange.Question do
  @moduledoc """
  TBD
  """

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  schema "question" do
    field :description, :string

    has_many :options, CraqValidator.RequestForChange.Option

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
