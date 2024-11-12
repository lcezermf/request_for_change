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

      changeset = Response.changeset(%Response{}, %{question_id: question.id})
      refute changeset.valid?
    end
  end
end
