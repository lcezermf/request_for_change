defmodule CraqValidator.RequestForChange.Question do
  @moduledoc """
  Question schema to store information about a question
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "questions" do
    field :description, :string
    field :kind, :string
    field :require_comment, :boolean, default: false

    has_many :options, CraqValidator.RequestForChange.Option

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:description, :kind, :require_comment])
  end
end
