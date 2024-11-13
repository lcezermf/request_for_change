defmodule CraqValidator.RequestForChange.Response do
  @moduledoc """
  TBD
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "responses" do
    field :selected_option_id, :integer
    field :comment, :string

    field :question_kind, :string, virtual: true

    belongs_to :question, CraqValidator.RequestForChange.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:selected_option_id, :question_id, :question_kind, :comment])
    |> maybe_validate_selected_option()
  end

  defp maybe_validate_selected_option(%{changes: %{question_kind: "multiple_choice"}} = changeset) do
    changeset
    |> validate_required(:selected_option_id)
  end

  defp maybe_validate_selected_option(changeset), do: changeset
end
