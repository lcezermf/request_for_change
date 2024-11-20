defmodule CraqValidatorWeb.RequestForChangeLive.FormTest do
  use CraqValidatorWeb.ConnCase

  import Phoenix.LiveViewTest

  alias CraqValidator.Factory
  alias CraqValidator.Repo
  alias CraqValidator.RequestForChange.Response

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

    assert has_element?(view, "span[data-question-id=#{question_one.id}]", "can't be blank")
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

    assert has_element?(view, "span[data-question-id=#{question_two.id}]", "can't be blank")
  end

  test "must not render error when all options are selected and create a response record",
       %{
         conn: conn
       } do
    assert Repo.aggregate(Response, :count, :id) == 0

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

    assert Repo.aggregate(Response, :count, :id) == 2
  end

  test "must create response record when type os free text", %{conn: conn} do
    assert Repo.aggregate(Response, :count, :id) == 0

    question_one = Factory.insert!(:question, %{kind: "free_text"})

    {:ok, view, _html} = access_form_submission_page(conn)

    view
    |> element("#comment_#{question_one.id}")
    |> render_blur(%{
      "value" => "Comment",
      "question_id" => "#{question_one.id}"
    })

    view
    |> form("#craq_form")
    |> render_submit()

    assert Repo.aggregate(Response, :count, :id) == 1
  end

  test "must create response record when type is multiple_choice and has text", %{conn: conn} do
    assert Repo.aggregate(Response, :count, :id) == 0

    question_one = Factory.insert!(:question)

    option_one = Factory.insert!(:option, question_id: question_one.id)
    Factory.insert!(:option, question_id: question_one.id)

    {:ok, view, _html} = access_form_submission_page(conn)

    view
    |> element("##{option_one.id}")
    |> render_click()

    view
    |> element("#comment_#{question_one.id}")
    |> render_blur(%{
      "value" => "Comment",
      "question_id" => "#{question_one.id}"
    })

    view
    |> form("#craq_form")
    |> render_submit()

    assert Repo.aggregate(Response, :count, :id) == 1
  end

  test "must create response record when type is multiple_choice and has text as required", %{
    conn: conn
  } do
    assert Repo.aggregate(Response, :count, :id) == 0

    question_one = Factory.insert!(:question)

    option_one = Factory.insert!(:option, question_id: question_one.id)
    Factory.insert!(:option, question_id: question_one.id)

    {:ok, view, _html} = access_form_submission_page(conn)

    view
    |> element("##{option_one.id}")
    |> render_click()

    view
    |> element("#comment_#{question_one.id}")
    |> render_blur(%{
      "value" => "Comment",
      "question_id" => "#{question_one.id}"
    })

    view
    |> form("#craq_form")
    |> render_submit()

    assert Repo.aggregate(Response, :count, :id) == 1
  end

  test "must not create response record when type is multiple_choice and has text required as blank",
       %{
         conn: conn
       } do
    assert Repo.aggregate(Response, :count, :id) == 0

    question_one = Factory.insert!(:question, %{require_comment: true})

    option_one = Factory.insert!(:option, question_id: question_one.id)
    Factory.insert!(:option, question_id: question_one.id)

    {:ok, view, _html} = access_form_submission_page(conn)

    view
    |> element("##{option_one.id}")
    |> render_click()

    view
    |> form("#craq_form")
    |> render_submit()

    refute has_element?(view, "#flash-info", "CRAQ submitted successfully!")

    assert has_element?(
             view,
             "span[data-comment-question-id=#{question_one.id}]",
             "can't be blank"
           )

    assert Repo.aggregate(Response, :count, :id) == 0
  end

  test "must disable following questions upon picking a terminal option and only store the valid ones",
       %{conn: conn} do
    question_one = Factory.insert!(:question)

    option_one = Factory.insert!(:option, question_id: question_one.id)
    option_two = Factory.insert!(:option, question_id: question_one.id)

    question_two = Factory.insert!(:question)

    option_three = Factory.insert!(:option, question_id: question_two.id)
    option_four = Factory.insert!(:option, question_id: question_two.id, is_terminal: true)

    question_three = Factory.insert!(:question)

    option_five = Factory.insert!(:option, question_id: question_three.id)
    option_six = Factory.insert!(:option, question_id: question_three.id)

    {:ok, view, _html} = access_form_submission_page(conn)

    assert has_element?(view, "##{option_one.id}")
    assert has_element?(view, "##{option_two.id}")
    assert has_element?(view, "##{option_three.id}")
    assert has_element?(view, "##{option_four.id}")
    assert has_element?(view, "##{option_five.id}")
    assert has_element?(view, "##{option_six.id}")

    assert has_element?(view, "#fieldset-#{question_one.id}")
    assert has_element?(view, "#fieldset-#{question_two.id}")
    assert has_element?(view, "#fieldset-#{question_three.id}")

    refute has_element?(view, "#fieldset-#{question_one.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_two.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_three.id}[disabled]")

    view
    |> element("##{option_two.id}")
    |> render_click()

    view
    |> element("##{option_four.id}")
    |> render_click()

    refute has_element?(view, "#fieldset-#{question_one.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_two.id}[disabled]")
    assert has_element?(view, "#fieldset-#{question_three.id}[disabled]")

    view
    |> form("#craq_form")
    |> render_submit()

    assert Repo.aggregate(Response, :count, :id) == 2
  end

  test "must guarantee that only the question that has a terminal option can undo the terminal option selection",
       %{conn: conn} do
    question_one = Factory.insert!(:question)

    option_one = Factory.insert!(:option, question_id: question_one.id)
    option_two = Factory.insert!(:option, question_id: question_one.id)

    question_two = Factory.insert!(:question)

    option_three = Factory.insert!(:option, question_id: question_two.id)
    option_four = Factory.insert!(:option, question_id: question_two.id, is_terminal: true)

    question_three = Factory.insert!(:question)

    option_five = Factory.insert!(:option, question_id: question_three.id)
    option_six = Factory.insert!(:option, question_id: question_three.id)

    {:ok, view, _html} = access_form_submission_page(conn)

    assert has_element?(view, "##{option_one.id}")
    assert has_element?(view, "##{option_two.id}")
    assert has_element?(view, "##{option_three.id}")
    assert has_element?(view, "##{option_four.id}")
    assert has_element?(view, "##{option_five.id}")
    assert has_element?(view, "##{option_six.id}")

    assert has_element?(view, "#fieldset-#{question_one.id}")
    assert has_element?(view, "#fieldset-#{question_two.id}")
    assert has_element?(view, "#fieldset-#{question_three.id}")

    refute has_element?(view, "#fieldset-#{question_one.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_two.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_three.id}[disabled]")

    # Select option to question #1
    view
    |> element("##{option_two.id}")
    |> render_click()

    # Select option to question #2 and disabled the remaining
    view
    |> element("##{option_four.id}")
    |> render_click()

    refute has_element?(view, "#fieldset-#{question_one.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_two.id}[disabled]")
    assert has_element?(view, "#fieldset-#{question_three.id}[disabled]")

    # Change the selected option to question #1 - this must not enable the remaining questions
    view
    |> element("##{option_one.id}")
    |> render_click()

    refute has_element?(view, "#fieldset-#{question_one.id}[disabled]")
    refute has_element?(view, "#fieldset-#{question_two.id}[disabled]")
    assert has_element?(view, "#fieldset-#{question_three.id}[disabled]")
  end

  test "must create options with confirmations disabled is case option require confirmation", %{
    conn: conn
  } do
    question_one = Factory.insert!(:question)

    option_one =
      Factory.insert!(:option, %{question_id: question_one.id, require_confirmation: true})

    option_two = Factory.insert!(:option, %{question_id: question_one.id})

    confirmation_one = Factory.insert!(:confirmation, %{option: option_one})
    confirmation_two = Factory.insert!(:confirmation, %{option: option_one})

    {:ok, view, _html} = access_form_submission_page(conn)

    assert has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
    assert has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")

    view
    |> element("##{option_one.id}")
    |> render_click()

    refute has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
    refute has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")

    view
    |> element("##{option_two.id}")
    |> render_click()

    assert has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
    assert has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")

    view
    |> element("##{option_one.id}")
    |> render_click()

    refute has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
    refute has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")

    view
    |> element("#confirmation-#{confirmation_one.id}")
    |> render_click()

    view
    |> form("#craq_form")
    |> render_submit()

    assert Repo.aggregate(Response, :count, :id) == 1
  end

  # test "must guarantee that only options of the same question can disabled/enable confirmations",
  #      %{
  #        conn: conn
  #      } do
  #   question_one = Factory.insert!(:question)

  #   option_one =
  #     Factory.insert!(:option, %{question_id: question_one.id, require_confirmation: true})

  #   option_two = Factory.insert!(:option, %{question_id: question_one.id})

  #   confirmation_one = Factory.insert!(:confirmation, %{option: option_one})
  #   confirmation_two = Factory.insert!(:confirmation, %{option: option_one})

  #   question_two = Factory.insert!(:question)

  #   option_three = Factory.insert!(:option, %{question_id: question_two.id})
  #   option_four = Factory.insert!(:option, %{question_id: question_two.id})

  #   {:ok, view, _html} = access_form_submission_page(conn)

  #   assert has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
  #   assert has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")

  #   view
  #   |> element("##{option_one.id}")
  #   |> render_click()

  #   refute has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
  #   refute has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")

  #   view
  #   |> element("##{option_three.id}")
  #   |> render_click()

  #   refute has_element?(view, "#confirmation-#{confirmation_one.id}[disabled]")
  #   refute has_element?(view, "#confirmation-#{confirmation_two.id}[disabled]")
  # end

  defp access_form_submission_page(conn) do
    conn
    |> get(~p"/request_for_change")
    |> live()
  end
end
