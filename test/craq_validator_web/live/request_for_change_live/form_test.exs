defmodule CraqValidatorWeb.RequestForChangeLive.FormTest do
  use CraqValidatorWeb.ConnCase

  import Phoenix.LiveViewTest

  alias CraqValidator.Factory

  describe "renders page" do
    test "must render the page with questions", %{
      conn: conn
    } do
      question_one = Factory.insert!(:question)

      option_one = Factory.insert!(:option, question_id: question_one.id)
      option_two = Factory.insert!(:option, question_id: question_one.id)

      {:ok, view, html} = access_form_submission_page(conn)

      assert html =~ "Answer Questions"

      assert has_element?(view, "p.text-lg.font-semibold", question_one.description)
      assert has_element?(view, "input[id=#{option_one.id}]")
      assert has_element?(view, "input[id=#{option_two.id}]")
    end
  end

  describe "rendering errors" do
    test "must render error when a single multiple choice question is not completed", %{
      conn: conn
    } do
      question_one = Factory.insert!(:question)

      Factory.insert!(:option, question_id: question_one.id)
      Factory.insert!(:option, question_id: question_one.id)

      {:ok, view, _html} = access_form_submission_page(conn)

      view
      |> form("#craq_form")
      |> render_submit()

      assert has_element?(view, "span.error", "Required")
    end

    test "must render error when there are many multiple choice questions and at least one is not completed",
         %{
           conn: conn
         } do
      question_one = Factory.insert!(:question)

      option_one = Factory.insert!(:option, question_id: question_one.id)
      Factory.insert!(:option, question_id: question_one.id)

      question_two = Factory.insert!(:question)

      Factory.insert!(:option, question_id: question_two.id)
      Factory.insert!(:option, question_id: question_two.id)

      {:ok, view, _html} = access_form_submission_page(conn)

      view
      |> element("##{option_one.id}")
      |> render_click()

      view
      |> form("#craq_form")
      |> render_submit()

      assert has_element?(view, "span[data-question-id=#{question_two.id}]", "Required")
    end

    test "must not render error when all options are selected and create a form_submission record",
         %{
           conn: conn
         } do
      question_one = Factory.insert!(:question)

      option_one = Factory.insert!(:option, question_id: question_one.id)
      Factory.insert!(:option, question_id: question_one.id)

      question_two = Factory.insert!(:question)

      Factory.insert!(:option, question_id: question_two.id)
      option_four = Factory.insert!(:option, question_id: question_two.id)

      {:ok, view, _html} = access_form_submission_page(conn)

      view
      |> element("##{option_one.id}")
      |> render_click()

      view
      |> element("##{option_four.id}")
      |> render_click()

      view
      |> form("#craq_form")
      |> render_submit()

      assert has_element?(view, "#flash-info", "CRAQ submitted successfully!")

      refute has_element?(view, "span[data-question-id=#{question_one.id}]", "Required")
      refute has_element?(view, "span[data-question-id=#{question_two.id}]", "Required")
    end
  end

  defp access_form_submission_page(conn) do
    conn
    |> get(~p"/request_for_change")
    |> live()
  end
end
