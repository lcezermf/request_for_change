defmodule CraqValidator.RequestForChange.Confirmation do
  @moduledoc """
  Confirmation schema to store information about a confirmation
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "confirmations" do
    field :description

    belongs_to :option, CraqValidator.RequestForChange.Option

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(confirmation, attrs) do
    confirmation
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
