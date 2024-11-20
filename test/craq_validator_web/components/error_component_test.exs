defmodule CraqValidatorWeb.ErrorComponentTest do
  use CraqValidatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CraqValidatorWeb.ErrorComponent

  describe "error_field/1" do
    test "do not render component when count is 0 (edge case)" do
      assigns = %{
        question_id: 1,
        disabled_questions_ids: [2, 3],
        has_submitted: true,
        responses: %{1 => %{errors: [confirmations: {"can't be blank", [validation: :required]}]}},
        field: :confirmations
      }

      rendered_component_html = render_component(&ErrorComponent.error_field/1, assigns)

      assert rendered_component_html =~
               ~s(\n  <div class=\"mt-2 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative\" role=\"alert\">\n    <span data-question-id=\"1\">\n      can&#39;t be blank\n    </span>\n  </div>\n)
    end
  end
end
