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
    field :question_require_comment, :boolean, virtual: true

    belongs_to :question, CraqValidator.RequestForChange.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [
      :selected_option_id,
      :comment,
      :question_kind,
      :question_require_comment,
      :question_id
    ])
    |> maybe_validate_selected_option()
    |> maybe_validate_comment()
  end

  defp maybe_validate_selected_option(%{changes: %{question_kind: "multiple_choice"}} = changeset) do
    changeset
    |> validate_required(:selected_option_id)
  end

  defp maybe_validate_selected_option(changeset), do: changeset

  defp maybe_validate_comment(%{changes: %{question_require_comment: true}} = changeset) do
    changeset
    |> validate_required(:comment)
  end

  defp maybe_validate_comment(changeset), do: changeset
end
