defmodule CraqValidator.RequestForChange.FormSubmission do
  @moduledoc """
  TBD
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "form_submissions" do
    field :answers, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(form_submission, attrs) do
    form_submission
    |> cast(attrs, [:answers])
  end
end
