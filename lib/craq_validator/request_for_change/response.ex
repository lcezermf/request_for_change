defmodule CraqValidator.RequestForChange.Response do
  @moduledoc """
  Response schema to store information about a response

  The schema is responsible for coordinating the validations based on the inputs (questions and options).
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "responses" do
    field :option_id, :integer
    field :comment, :string
    field :form_public_id, :binary_id
    field :confirmations, {:array, :integer}

    field :question_kind, :string, virtual: true
    field :question_require_comment, :boolean, virtual: true
    field :option_is_terminal, :boolean, virtual: true
    field :option_require_confirmation, :boolean, virtual: true

    belongs_to :question, CraqValidator.RequestForChange.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [
      :option_id,
      :comment,
      :question_kind,
      :question_require_comment,
      :question_id,
      :option_is_terminal,
      :form_public_id,
      :option_require_confirmation,
      :confirmations
    ])
    |> maybe_delete_previous_errors()
    |> maybe_validate_selected_option()
    |> maybe_validate_comment()
    |> maybe_validate_confirmation()
    |> maybe_remove_validations()
  end

  defp maybe_validate_selected_option(%{changes: %{question_kind: "multiple_choice"}} = changeset) do
    changeset
    |> validate_required(:option_id)
  end

  defp maybe_validate_selected_option(changeset), do: changeset

  defp maybe_validate_comment(%{changes: %{question_require_comment: true}} = changeset) do
    changeset
    |> validate_required(:comment)
  end

  defp maybe_validate_comment(changeset), do: changeset

  defp maybe_delete_previous_errors(%{valid?: true} = changeset), do: changeset

  defp maybe_delete_previous_errors(%{changes: changes, errors: errors} = changeset) do
    changed_values_keys = Map.keys(changes)
    remaining_errors = Enum.reject(errors, fn {key, _} -> key in changed_values_keys end)

    %{changeset | errors: remaining_errors, valid?: remaining_errors == []}
  end

  defp maybe_remove_validations(%{changes: %{option_is_terminal: true}} = changeset) do
    %{changeset | errors: [], valid?: true}
  end

  defp maybe_remove_validations(changeset), do: changeset

  defp maybe_validate_confirmation(%{changes: %{option_require_confirmation: true}} = changeset) do
    changeset
    |> validate_required(:confirmations)
    |> validate_length(:confirmations, min: 1)
  end

  defp maybe_validate_confirmation(changeset), do: changeset
end
