defmodule CraqValidator.RequestForChange.Question do
  @moduledoc """
  TBD
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "questions" do
    field :description, :string
    field :kind, :string

    has_many :options, CraqValidator.RequestForChange.Option

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:description])
  end
end
