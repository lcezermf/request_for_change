defmodule CraqValidator.RequestForChange.FormSubmission do
  @moduledoc """
  TBD
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "form_submissions" do
    field :selected_option_id, :integer

    belongs_to :question, CraqValidator.RequestForChange.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(form_submission, attrs) do
    form_submission
    |> cast(attrs, [:selected_option_id])
  end
end
