defmodule CraqValidatorWeb.RequestForChangeLive.FormTest do
  use CraqValidatorWeb.ConnCase

  import Phoenix.LiveViewTest

  alias CraqValidator.Factory

  describe "renders page" do
    setup [:create_one_question_with_options]

    test "renders the page with questions", %{conn: conn, question_one: question_one} do
      {:ok, view, html} = get(conn, ~p"/request_for_change") |> live()

      assert html =~ "Answer Questions"

      assert has_element?(view, "p.text-lg.font-semibold", question_one.description)
    end
  end

  defp create_one_question_with_options(_context) do
    question_one = Factory.insert!(:question)

    option_one = Factory.insert!(:option, question_id: question_one.id)
    option_two = Factory.insert!(:option, question_id: question_one.id)

    %{question_one: question_one, option_one: option_one, option_two: option_two}
  end
end
