defmodule CraqValidatorWeb.PendingResponsesComponentTest do
  use CraqValidatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CraqValidatorWeb.PendingResponsesComponent

  describe "show_progress_message/1" do
    test "must render message saying that there are pending values" do
      assigns = %{
        total: 1
      }

      rendered_component_html =
        render_component(&PendingResponsesComponent.show_progress_message/1, assigns)

      assert rendered_component_html =~ "You have pending responses, please check the form."
    end

    test "must render message saying that there are no pending values" do
      assigns = %{
        total: 0
      }

      rendered_component_html =
        render_component(&PendingResponsesComponent.show_progress_message/1, assigns)

      assert rendered_component_html =~ "All set!"
    end
  end
end
