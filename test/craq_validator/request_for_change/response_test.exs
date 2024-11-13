defmodule CraqValidator.RequestForChange.ResponseTest do
  use CraqValidator.DataCase

  alias CraqValidator.RequestForChange.Response
  alias CraqValidator.Factory

  describe "validations" do
    test "must validate selected_option_id when question is of type multiple choice" do
      question = Factory.insert!(:question, %{kind: "multiple_choice"})
      Factory.insert!(:option, %{question: question})

      changeset = Response.changeset(%Response{}, %{})
      assert changeset.valid?

      changeset =
        Response.changeset(%Response{}, %{question_id: question.id, question_kind: question.kind})

      refute changeset.valid?
    end

    test "must not validate selected_option_id when question is of type free_text" do
      question = Factory.insert!(:question, %{kind: "free_text"})
      Factory.insert!(:option, %{question: question})

      changeset = Response.changeset(%Response{}, %{})
      assert changeset.valid?

      changeset =
        Response.changeset(%Response{}, %{question_id: question.id, question_kind: question.kind})

      assert changeset.valid?
    end
  end
end
