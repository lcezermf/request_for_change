defmodule CraqValidator.RequestForChange.Response do
  @moduledoc """
  TBD
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias CraqValidator.RequestForChange

  @type t :: %__MODULE__{}

  schema "responses" do
    field :selected_option_id, :integer
    field :comment, :string

    belongs_to :question, CraqValidator.RequestForChange.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:selected_option_id, :question_id, :comment])
    |> maybe_validate_selected_option()
  end

  defp maybe_validate_selected_option(%{changes: %{question_id: question_id}} = changeset) do
    question = RequestForChange.get_question_by_id(question_id)

    cond do
      is_nil(question) ->
        changeset

      question.kind == "multiple_choice" ->
        validate_required(changeset, :selected_option_id)

      true ->
        changeset
    end
  end

  defp maybe_validate_selected_option(changeset), do: changeset
end
