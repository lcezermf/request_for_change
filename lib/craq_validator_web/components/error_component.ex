defmodule CraqValidatorWeb.ErrorComponent do
  @moduledoc """
  Component to render errors for fields
  """

  use Phoenix.Component

  attr :question_id, :integer, required: true
  attr :disabled_questions_ids, :list, required: true
  attr :has_submitted, :boolean, required: true
  attr :responses, :list, required: true
  attr :field, :atom, required: true

  def error_field(assigns) do
    ~H"""
    <%= if @question_id not in @disabled_questions_ids and @has_submitted and @responses[@question_id].errors[@field] do %>
      <div
        class="mt-2 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative"
        role="alert"
      >
        <span data-question-id={@question_id}>
          <%= CraqValidatorWeb.CoreComponents.translate_errors(
            @responses[@question_id].errors,
            @field
          ) %>
        </span>
      </div>
    <% end %>
    """
  end
end
