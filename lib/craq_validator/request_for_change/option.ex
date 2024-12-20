defmodule CraqValidator.RequestForChange.Option do
  @moduledoc """
  Option schema to store information about an option
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.RequestForChange.Confirmation

  @type t :: %__MODULE__{}

  schema "options" do
    field :description, :string
    field :is_terminal, :boolean, default: false
    field :require_confirmation, :boolean, default: false

    belongs_to :question, Question

    has_many :confirmations, Confirmation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:description, :is_terminal])
  end
end
