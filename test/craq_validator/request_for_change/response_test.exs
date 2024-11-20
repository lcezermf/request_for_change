defmodule CraqValidator.RequestForChange.ResponseTest do
  use CraqValidator.DataCase

  alias CraqValidator.RequestForChange.Response
  alias CraqValidator.Factory

  describe "validations" do
    test "must validate option_id when question is of type multiple choice" do
      question = Factory.insert!(:question, %{kind: "multiple_choice"})
      Factory.insert!(:option, %{question: question})

      changeset = Response.changeset(%Response{}, %{})
      assert changeset.valid?

      changeset =
        Response.changeset(%Response{}, %{question_id: question.id, question_kind: question.kind})

      refute changeset.valid?
      assert %{option_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "must not validate option_id when question is of type free_text" do
      question = Factory.insert!(:question, %{kind: "free_text"})

      changeset = Response.changeset(%Response{}, %{})
      assert changeset.valid?

      changeset =
        Response.changeset(%Response{}, %{question_id: question.id, question_kind: question.kind})

      assert changeset.valid?
    end

    test "must validate comment when question is multiple choice and require comment" do
      question = Factory.insert!(:question, %{kind: "multiple_choice", require_comment: true})
      option = Factory.insert!(:option, %{question: question})

      changeset = Response.changeset(%Response{}, %{})
      assert changeset.valid?

      changeset =
        Response.changeset(%Response{}, %{
          option_id: option.id,
          question_id: question.id,
          question_kind: question.kind,
          question_require_comment: question.require_comment
        })

      refute changeset.valid?
      assert %{comment: ["can't be blank"]} == errors_on(changeset)
    end

    test "must not validate when question is multiple choice and require comment and return valid" do
      question = Factory.insert!(:question, %{kind: "multiple_choice", require_comment: true})
      option = Factory.insert!(:option, %{question: question})

      changeset = Response.changeset(%Response{}, %{})
      assert changeset.valid?

      changeset =
        Response.changeset(%Response{}, %{
          option_id: option.id,
          question_id: question.id,
          question_kind: question.kind,
          question_require_comment: question.require_comment,
          comment: "OK"
        })

      assert changeset.valid?
    end

    test "must remove validations when option of question is a terminal option" do
      question = Factory.insert!(:question, %{kind: "multiple_choice", require_comment: true})
      option = Factory.insert!(:option, %{question: question})
      option_terminal = Factory.insert!(:option, %{question: question, is_terminal: true})

      changeset =
        Response.changeset(%Response{}, %{
          option_id: option.id,
          question_id: question.id,
          question_kind: question.kind,
          question_require_comment: question.require_comment
        })

      refute changeset.valid?
      assert %{comment: ["can't be blank"]} == errors_on(changeset)

      changeset =
        Response.changeset(changeset, %{
          option_is_terminal: option_terminal.is_terminal
        })

      assert changeset.valid?
    end
  end

  test "must validate when a option require confirmation" do
    question = Factory.insert!(:question, %{kind: "multiple_choice"})
    Factory.insert!(:option, %{question: question})
    option_two = Factory.insert!(:option, %{question: question})
    Factory.insert!(:confirmation, %{option: option_two})
    Factory.insert!(:confirmation, %{option: option_two})

    changeset =
      Response.changeset(%Response{}, %{
        option_id: option_two.id,
        question_id: question.id,
        question_kind: question.kind,
        option_require_confirmation: true,
        confirmations: []
      })

    refute changeset.valid?
    assert %{confirmations: ["should have at least 1 item(s)"]} == errors_on(changeset)

    changeset =
      Response.changeset(changeset, %{
        confirmations: [1]
      })

    assert changeset.valid?
  end
end
